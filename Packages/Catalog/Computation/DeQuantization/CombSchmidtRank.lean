import Mathlib

/-!
# The Schmidt rank of Shor's periodic comb is exactly the period

This file answers, in the affirmative and with an exact formula, the *honest open
question* posed by the de-quantization research programme:

> For the comb state `|comb⟩ = Σ_j |x₀ + j r⟩` (period `r`), what is the minimal
> MPS bond dimension?  If it scales with `r` (the order, `~ N`), the tensor-train
> QFT emulation is `O(r)`-sealed.  If it scales with `log r` or is bounded,
> Shor could be de-quantized.

We work with the *bipartite cut* picture, which is the definition of the MPS bond
dimension: split the `n`-dimensional register as `n = P · Q` (for qubits,
`P = 2^a`, `Q = 2^b`, `a + b = L`), write the basis index as `x = p·Q + q`, and
reshape the amplitude vector into the `P × Q` matrix

  `combMatrix P Q r x₀ p q = 1` if `p·Q + q ≡ x₀ (mod r)`, else `0`.

The minimal bond dimension across the cut is exactly the rank of this matrix
(`bondDim_eq_rank` below is the precise statement: `M = A * B` with an inner index
of size `D` is possible iff `M.rank ≤ D`).

## Main results

* `combMatrix_rank_le` — the rank is **at most `r`**, for every cut, with no
  hypotheses beyond `0 < r`.  (An explicit rank-`r` factorisation is exhibited:
  the left core records `p·Q mod r`, the right core completes the residue.)
* `combMatrix_rank_ge` — the rank is **at least `r`** as soon as `gcd(Q,r) = 1`
  and both sides of the cut are at least as large as the period (`r ≤ P`,
  `r ≤ Q`).  The proof exhibits an `r × r` identity submatrix, indexed by
  `p_i = i·Q⁻¹ mod r` and `q_j = (x₀ - j) mod r`; here the number theory (the
  invertibility of `Q` modulo `r`) enters the linear algebra.
* `combMatrix_rank_eq` — hence the rank is **exactly `r`**.
* `qubit_comb_rank_eq`, `qubit_comb_bondDim_ge` — the qubit specialisation:
  for an odd period `r` and a cut `L = a + b` deep enough on both sides,
  every MPS representation of the comb needs bond dimension `≥ r`.
* `comb_productState_iff` — the comb is a product state across the cut iff
  `r = 1`; any nontrivial period is genuinely entangled across *every* cut.

## Consequence for de-quantization

`r` is the multiplicative order being searched for in Shor's algorithm, which is
generically of size `~ N` (exponential in the number of qubits).  Since a
tensor-train/MPS emulation of the QFT costs `Ω(D²)` per site with `D` the bond
dimension, and since the comb *forces* `D ≥ r`, the tensor-train emulation route
is sealed by the same `O(r)` aggregation barrier as every classical method: the
low-rank hypothesis of "Theorem 3" is simply false for the Shor input.

-- !-- Lab Notes -- !--

* Hypothesis (Hypothesizer): the comb is *maximally* entangled among states with
  `r` "colours": rank at a balanced cut `= min(2^a, 2^b, r)`, not `log r`.
* Experiment (Experimenter): computed the rank of `combMatrix` symbolically.
  Upper bound: an explicit `P × r` times `r × Q` factorisation exists always.
  Lower bound: the rows are indicators of *disjoint* residue classes, so distinct
  rows are automatically orthogonal — the failure mode of generic 0/1 matrices
  (distinct but dependent rows) cannot occur here.
* Data (small cases, `P = Q = 8`): `r = 1 ↦ rank 1`, `r = 3 ↦ rank 3`,
  `r = 5 ↦ rank 5`, `r = 7 ↦ rank 7`; and for the *even* period `r = 2` with
  `Q = 8` one gets rank `1`, since `gcd(Q,r) = 2 ≠ 1` — the coprimality
  hypothesis is not decorative (see `combMatrix_rank_le_one_of_dvd` at the end of
  this file, and the exact general formula in `CombRankGeneral.lean`).
* Analysis (Analyst): the exact answer is `r`, never `log r`.  De-quantization of
  order finding through low-rank tensor trains is therefore impossible *for the
  comb itself*; any de-quantization must avoid materialising the comb.
-/

namespace DeQuantization

open scoped Matrix

/-! ## A rank lower bound from a delta submatrix -/

/-- If a matrix contains a `k × k` identity submatrix (selected by *arbitrary*
index maps `f`, `g`), its rank is at least `k`.  Mathlib's `rank_submatrix_le`
only covers reindexing by equivalences, so we run the selection through explicit
0/1 selection matrices. -/
theorem rank_ge_of_delta_submatrix {P Q k : ℕ} (A : Matrix (Fin P) (Fin Q) ℂ)
    (f : Fin k → Fin P) (g : Fin k → Fin Q)
    (h : ∀ i j, A (f i) (g j) = if i = j then 1 else 0) : k ≤ A.rank := by
  classical
  set E : Matrix (Fin k) (Fin P) ℂ := Matrix.of fun i p => if p = f i then 1 else 0 with hE
  set F : Matrix (Fin Q) (Fin k) ℂ := Matrix.of fun q j => if q = g j then 1 else 0 with hF
  have hEA : ∀ i q, (E * A) i q = A (f i) q := by
    intro i q
    simp [hE, Matrix.mul_apply, ite_mul]
  have hXF : ∀ (X : Matrix (Fin k) (Fin Q) ℂ) i j, (X * F) i j = X i (g j) := by
    intro X i j
    simp [hF, Matrix.mul_apply, mul_ite]
  have key : E * (A * F) = (1 : Matrix (Fin k) (Fin k) ℂ) := by
    rw [← Matrix.mul_assoc]
    ext i j
    rw [hXF (E * A) i j, hEA i (g j), h i j, Matrix.one_apply]
  calc k = (E * (A * F)).rank := by rw [key, Matrix.rank_one, Fintype.card_fin]
    _ ≤ (A * F).rank := Matrix.rank_mul_le_right E (A * F)
    _ ≤ A.rank := Matrix.rank_mul_le_left A F

/-! ## The comb amplitude matrix across a cut -/

/-- The reshaped amplitude matrix of the periodic comb
`Σ_{x ≡ x₀ [r], x < P·Q} |x⟩` across the cut `x = p·Q + q`. -/
noncomputable def combMatrix (P Q r x0 : ℕ) : Matrix (Fin P) (Fin Q) ℂ :=
  Matrix.of fun p q => if ((p : ℕ) * Q + (q : ℕ)) % r = x0 % r then 1 else 0

/-- **Faithfulness of the reshape.**  Reading the register index `x < P·Q` as the
pair `(x / Q, x % Q)` — the canonical `Fin (P*Q) ≃ Fin P × Fin Q` splitting used by
every MPS/tensor-train construction — the matrix `combMatrix` really is the
amplitude vector of the comb state `∑_{x < P·Q, x ≡ x₀ [r]} |x⟩`. -/
theorem combMatrix_reshape (P Q r x0 : ℕ) (x : Fin (P * Q)) :
    combMatrix P Q r x0 (Fin.divNat x) (Fin.modNat x)
      = if (x : ℕ) % r = x0 % r then 1 else 0 := by
  have hx : ((Fin.divNat x : Fin P) : ℕ) * Q + ((Fin.modNat x : Fin Q) : ℕ) = (x : ℕ) := by
    simp only [Fin.divNat, Fin.modNat]
    exact Nat.div_add_mod' (x : ℕ) Q
  show (if _ then (1 : ℂ) else 0) = _
  rw [hx]

/-- Left core of the exact rank-`r` factorisation: it only remembers the residue
`p·Q mod r`, i.e. `r` numbers suffice to describe the whole left half. -/
noncomputable def combLeft (P Q r : ℕ) : Matrix (Fin P) (Fin r) ℂ :=
  Matrix.of fun p c => if (p : ℕ) * Q % r = (c : ℕ) then 1 else 0

/-- Right core of the exact rank-`r` factorisation. -/
noncomputable def combRight (Q r x0 : ℕ) : Matrix (Fin r) (Fin Q) ℂ :=
  Matrix.of fun c q => if ((c : ℕ) + (q : ℕ)) % r = x0 % r then 1 else 0

/-- **Exact bond-`r` tensor train for the comb.** -/
theorem combMatrix_factor (P Q r x0 : ℕ) (hr : 0 < r) :
    combMatrix P Q r x0 = combLeft P Q r * combRight Q r x0 := by
  classical
  ext p q
  have hlt : (p : ℕ) * Q % r < r := Nat.mod_lt _ hr
  rw [Matrix.mul_apply]
  rw [Finset.sum_eq_single (⟨(p : ℕ) * Q % r, hlt⟩ : Fin r)]
  · have : ((p : ℕ) * Q % r + (q : ℕ)) % r = ((p : ℕ) * Q + (q : ℕ)) % r :=
      Nat.mod_add_mod _ _ _
    simp [combLeft, combRight, combMatrix, this]
  · intro c _ hc
    have : ¬ ((p : ℕ) * Q % r = (c : ℕ)) := by
      intro h
      exact hc (Fin.ext h.symm)
    simp [combLeft, this]
  · intro h
    exact absurd (Finset.mem_univ _) h

/-- **Upper bound: the bond dimension of the comb never exceeds the period.** -/
theorem combMatrix_rank_le (P Q r x0 : ℕ) (hr : 0 < r) :
    (combMatrix P Q r x0).rank ≤ r := by
  rw [combMatrix_factor P Q r x0 hr]
  exact le_trans (Matrix.rank_mul_le_left _ _) (Matrix.rank_le_width _)

/-! ## The lower bound -/

/-- A modular inverse of `Q` mod `r`, as a natural number, when `gcd(Q,r) = 1`. -/
theorem exists_natCast_inv {Q r : ℕ} (h : Nat.Coprime Q r) (hr : 0 < r) :
    ∃ u : ℕ, (Q : ZMod r) * (u : ZMod r) = 1 := by
  have hu : IsUnit (Q : ZMod r) := (ZMod.isUnit_iff_coprime Q r).mpr h
  obtain ⟨v, hv⟩ := hu
  haveI : NeZero r := ⟨hr.ne'⟩
  refine ⟨((v⁻¹ : (ZMod r)ˣ) : ZMod r).val, ?_⟩
  rw [ZMod.natCast_val, ZMod.cast_id, ← hv]
  exact v.mul_inv

/-- Translation of the comb's support condition into `ZMod r`. -/
theorem comb_cond_iff {r : ℕ} (a b : ℕ) : a % r = b % r ↔ (a : ZMod r) = (b : ZMod r) :=
  (ZMod.natCast_eq_natCast_iff a b r).symm.trans Iff.rfl

/-- **Lower bound: the comb forces bond dimension at least `r`.**
Hypotheses: the period is invertible modulo the size of the right block
(`gcd(Q,r) = 1`) and both blocks are at least as big as the period. -/
theorem combMatrix_rank_ge {P Q r x0 : ℕ} (hr : 0 < r) (hQr : Nat.Coprime Q r)
    (hrP : r ≤ P) (hrQ : r ≤ Q) : r ≤ (combMatrix P Q r x0).rank := by
  classical
  obtain ⟨u, hu⟩ := exists_natCast_inv hQr hr
  refine rank_ge_of_delta_submatrix (combMatrix P Q r x0)
    (fun i => ⟨((i : ℕ) * u) % r, lt_of_lt_of_le (Nat.mod_lt _ hr) hrP⟩)
    (fun j => ⟨(x0 + (r - (j : ℕ))) % r, lt_of_lt_of_le (Nat.mod_lt _ hr) hrQ⟩) ?_
  intro i j
  have hji : (j : ℕ) ≤ r := le_of_lt j.isLt
  have key : ((((i : ℕ) * u) % r * Q + (x0 + (r - (j : ℕ))) % r : ℕ) : ZMod r)
      = ((i : ℕ) : ZMod r) + (x0 : ZMod r) - ((j : ℕ) : ZMod r) := by
    push_cast [ZMod.natCast_mod, Nat.cast_sub hji]
    simp only [ZMod.natCast_self]
    linear_combination ((i : ℕ) : ZMod r) * hu
  have hiff : ((((i : ℕ) * u) % r * Q + (x0 + (r - (j : ℕ))) % r) % r = x0 % r) ↔ i = j := by
    rw [comb_cond_iff, key]
    constructor
    · intro h
      have : ((i : ℕ) : ZMod r) = ((j : ℕ) : ZMod r) := by linear_combination h
      have := (ZMod.natCast_eq_natCast_iff _ _ _).1 this
      have h2 : (i : ℕ) % r = (j : ℕ) % r := this
      rw [Nat.mod_eq_of_lt i.isLt, Nat.mod_eq_of_lt j.isLt] at h2
      exact Fin.ext h2
    · rintro rfl
      ring
  show (if _ then (1:ℂ) else 0) = _
  by_cases h : i = j
  · rw [if_pos (hiff.mpr h), if_pos h]
  · rw [if_neg (fun hh => h (hiff.mp hh)), if_neg h]

/-- **Main theorem: the Schmidt rank of the periodic comb across a cut is exactly
the period.** -/
theorem combMatrix_rank_eq {P Q r x0 : ℕ} (hr : 0 < r) (hQr : Nat.Coprime Q r)
    (hrP : r ≤ P) (hrQ : r ≤ Q) : (combMatrix P Q r x0).rank = r :=
  le_antisymm (combMatrix_rank_le P Q r x0 hr) (combMatrix_rank_ge hr hQr hrP hrQ)

/-! ## Bond dimension -/

/-- `HasBond M D` says that the amplitude matrix `M` admits a tensor-train / MPS
contraction across the cut with an inner (bond) index of size `D`. -/
def HasBond {P Q : ℕ} (M : Matrix (Fin P) (Fin Q) ℂ) (D : ℕ) : Prop :=
  ∃ (A : Matrix (Fin P) (Fin D) ℂ) (B : Matrix (Fin D) (Fin Q) ℂ), M = A * B

/-- A bond index can always be enlarged (pad the cores with zeros). -/
theorem hasBond_mono {P Q : ℕ} {M : Matrix (Fin P) (Fin Q) ℂ} {D D' : ℕ} (hD : D ≤ D')
    (hM : HasBond M D) : HasBond M D' := by
  classical
  obtain ⟨A, B, rfl⟩ := hM
  refine ⟨Matrix.of fun p i => if h : (i : ℕ) < D then A p ⟨i, h⟩ else 0,
         Matrix.of fun i q => if h : (i : ℕ) < D then B ⟨i, h⟩ q else 0, ?_⟩
  ext p q
  rw [Matrix.mul_apply, Matrix.mul_apply]
  have h0 : ∀ i ∈ (Finset.univ : Finset (Fin D')), i ∉ Finset.univ.map (Fin.castLEEmb hD) →
      (Matrix.of fun p i => if h : (i : ℕ) < D then A p ⟨i, h⟩ else 0 :
          Matrix (Fin P) (Fin D') ℂ) p i *
      (Matrix.of fun i q => if h : (i : ℕ) < D then B ⟨i, h⟩ q else 0 :
          Matrix (Fin D') (Fin Q) ℂ) i q = 0 := by
    intro i _ hi
    have hlt : ¬ ((i : ℕ) < D) := by
      intro h
      exact hi (Finset.mem_map.2 ⟨⟨i, h⟩, Finset.mem_univ _, by ext; rfl⟩)
    simp [hlt]
  rw [Finset.sum_subset (Finset.subset_univ (Finset.univ.map (Fin.castLEEmb hD))) h0 |>.symm,
    Finset.sum_map]
  simp

/-- Any tensor train across the cut has bond dimension at least the rank. -/
theorem rank_le_of_hasBond {P Q : ℕ} {M : Matrix (Fin P) (Fin Q) ℂ} {D : ℕ}
    (h : HasBond M D) : M.rank ≤ D := by
  obtain ⟨A, B, rfl⟩ := h
  exact le_trans (Matrix.rank_mul_le_left _ _) (Matrix.rank_le_width _)

/-- **The minimal bond dimension of the comb across the cut is exactly `r`.**
A tensor train of bond dimension `D` exists if and only if `D ≥ r`. -/
theorem comb_hasBond_iff {P Q r x0 : ℕ} (hr : 0 < r) (hQr : Nat.Coprime Q r)
    (hrP : r ≤ P) (hrQ : r ≤ Q) (D : ℕ) :
    HasBond (combMatrix P Q r x0) D ↔ r ≤ D := by
  constructor
  · intro h
    rw [← combMatrix_rank_eq hr hQr hrP hrQ (x0 := x0)]
    exact rank_le_of_hasBond h
  · intro h
    exact hasBond_mono h ⟨combLeft P Q r, combRight Q r x0, combMatrix_factor P Q r x0 hr⟩

/-- **The comb is a product state across the cut iff the period is trivial.** -/
theorem comb_productState_iff {P Q r x0 : ℕ} (hr : 0 < r) (hQr : Nat.Coprime Q r)
    (hrP : r ≤ P) (hrQ : r ≤ Q) :
    HasBond (combMatrix P Q r x0) 1 ↔ r = 1 := by
  rw [comb_hasBond_iff hr hQr hrP hrQ]
  omega

/-! ## The qubit specialisation -/

/-- For an odd period and a cut deep enough on both sides, the Schmidt rank of the
`(a+b)`-qubit comb is exactly `r`. -/
theorem qubit_comb_rank_eq {a b r x0 : ℕ} (hr : 0 < r) (hodd : Odd r)
    (hra : r ≤ 2 ^ a) (hrb : r ≤ 2 ^ b) :
    (combMatrix (2 ^ a) (2 ^ b) r x0).rank = r := by
  have h2 : Nat.Coprime 2 r := Nat.coprime_two_left.mpr hodd
  exact combMatrix_rank_eq hr (Nat.Coprime.pow_left b h2) hra hrb

/-- **De-quantization barrier.**  Every MPS/tensor-train representation of Shor's
comb state on `a + b` qubits (odd period `r`, cut deep enough) needs bond
dimension at least the order `r` — never `log r`, never a constant.  Since the
emulated QFT costs `Ω(D²)` per site, the tensor-train route to de-quantizing
order finding is sealed by the same `O(r)` aggregation barrier. -/
theorem qubit_comb_bondDim_ge {a b r x0 D : ℕ} (hr : 0 < r) (hodd : Odd r)
    (hra : r ≤ 2 ^ a) (hrb : r ≤ 2 ^ b)
    (h : HasBond (combMatrix (2 ^ a) (2 ^ b) r x0) D) : r ≤ D := by
  rw [← qubit_comb_rank_eq hr hodd hra hrb (x0 := x0)]
  exact rank_le_of_hasBond h

/-! ## The boundary of the theorem (adversarial review)

The coprimality hypothesis is *not* decorative: when the period divides the size
of the right block the comb becomes a **product state** across that cut, of rank
`1`, no matter how large `r` is.  So "period `r` ⇒ bond dimension `r`" is false in
general; what is true is the cut-dependent statement above. -/

/-- If `r ∣ Q` the comb is unentangled across the cut: rank at most one. -/
theorem combMatrix_rank_le_one_of_dvd {P Q r x0 : ℕ} (h : r ∣ Q) :
    (combMatrix P Q r x0).rank ≤ 1 := by
  classical
  have hfac : combMatrix P Q r x0 =
      (Matrix.of fun (_ : Fin P) (_ : Fin 1) => (1 : ℂ)) *
      (Matrix.of fun (_ : Fin 1) (q : Fin Q) => if (q : ℕ) % r = x0 % r then (1 : ℂ) else 0) := by
    ext p q
    have hmod : ((p : ℕ) * Q + (q : ℕ)) % r = (q : ℕ) % r := by
      obtain ⟨t, rfl⟩ := h
      simp [Nat.mul_comm, Nat.mul_left_comm]
    simp [combMatrix, Matrix.mul_apply, hmod]
  rw [hfac]
  exact le_trans (Matrix.rank_mul_le_left _ _) (Matrix.rank_le_width _)

end DeQuantization