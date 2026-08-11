/-
# Diophantine–Lattice: Spectral Bounds on Non-Homogeneous Quadratic Forms

Self-contained development (Mathlib only) of *spectral gap* phenomena for
non-homogeneous (shifted) quadratic forms on the integer lattice `ℤⁿ`.

Setting: a real quadratic form `QF A x = ∑ᵢ ∑ⱼ Aᵢⱼ xᵢ xⱼ` which is *spectrally
sandwiched*, `m‖x‖² ≤ Q x ≤ M‖x‖²` (for a symmetric matrix, this holds exactly
when all eigenvalues lie in `[m, M]`), together with a shift `t ∈ ℝⁿ`.  The
associated non-homogeneous Diophantine problem is

  `Q(x - t) = c`,   `x ∈ ℤⁿ`.

Main results.

* `sq_distZ_le_sq_sub`, `sqDistLattice_le_sqNorm_sub` — the elementary
  lattice-reduction estimate: the coordinatewise distance to `ℤ` bounds the
  displacement of any integer point from below.
* `spectral_gap_lower` — `m · d(t, ℤⁿ)² ≤ Q(x - t)` for every `x ∈ ℤⁿ`.
* `spectral_gap_pos` / `no_integer_solution_below_gap` — if the shift is not a
  lattice point then the gap is *strictly positive*, so the equation
  `Q(x - t) = c` has **no** integer solution for `c` below the gap.
* `exists_le_covering` — the matching upper bound `Q(x₀ - t) ≤ M·n/4` obtained
  by rounding (a covering-radius estimate).
* `inhomMin_sandwich` — the two-sided *spectral sandwich* for the inhomogeneous
  minimum: `m·d(t,ℤⁿ)² ≤ μ(Q,t) ≤ M·n/4`.
* `card_solutions_le` — a counting bound: any finite set of integer solutions of
  `Q(x - t) ≤ R` has cardinality at most `(2√(R/m) + 1)ⁿ`; hence the theta
  coefficients (representation numbers) grow at most polynomially.
* `summable_theta`, `theta_ge`, `theta_decay` — the inhomogeneous theta series
  `Θ(s) = ∑_{x ∈ ℤⁿ} exp(-s·Q(x - t))` converges for every `s > 0`, is bounded
  below by `exp(-s·M·n/4)`, and decays at the exponential rate given by the
  spectral gap:  `Θ(s) ≤ exp(-(s - s₀)·m·d(t,ℤⁿ)²) · Θ(s₀)` for `s ≥ s₀ > 0`.
* `sum_sq_half_shift_ge` — a concrete Diophantine corollary: for every integer
  vector, `∑ᵢ (xᵢ - 1/2)² ≥ n/4`, with the sum-of-squares form realised as the
  identity-matrix instance of the general theory.
-/
import Mathlib

open Finset Real

namespace DiophantineLattice

variable {n : ℕ}

/-! ## Basic definitions -/

/-- Squared Euclidean norm of a vector in `ℝⁿ`. -/
def sqNorm (x : Fin n → ℝ) : ℝ := ∑ i, (x i) ^ 2

/-- The quadratic form attached to a matrix `A`. -/
def QF (A : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) : ℝ := ∑ i, ∑ j, A i j * x i * x j

/-- `A` has *spectral bounds* `m ≤ M`: the Rayleigh quotient of `QF A` is
sandwiched between `m` and `M`.  For a symmetric matrix this holds exactly when
all eigenvalues lie in `[m, M]`. -/
def HasSpectralBounds (A : Matrix (Fin n) (Fin n) ℝ) (m M : ℝ) : Prop :=
  ∀ x : Fin n → ℝ, m * sqNorm x ≤ QF A x ∧ QF A x ≤ M * sqNorm x

/-- Non-homogeneous evaluation `Q(x - t)` at an integer point `x`. -/
def inhomEval (A : Matrix (Fin n) (Fin n) ℝ) (t : Fin n → ℝ) (x : Fin n → ℤ) : ℝ :=
  QF A (fun i => (x i : ℝ) - t i)

/-- Distance from a real number to the integers. -/
noncomputable def distZ (u : ℝ) : ℝ := min (Int.fract u) (1 - Int.fract u)

/-- Squared Euclidean distance from `t` to the lattice `ℤⁿ`. -/
noncomputable def sqDistLattice (t : Fin n → ℝ) : ℝ := ∑ i, (distZ (t i)) ^ 2

/-! ## Diagonal instances of the spectral hypothesis -/

lemma QF_diagonal (d : Fin n → ℝ) (x : Fin n → ℝ) :
    QF (Matrix.diagonal d) x = ∑ i, d i * (x i) ^ 2 := by
  refine Finset.sum_congr rfl fun i _ => ?_
  rw [Finset.sum_eq_single i]
  · simp [Matrix.diagonal_apply_eq]; ring
  · intro j _ hj
    simp [Matrix.diagonal_apply_ne _ (Ne.symm hj)]
  · intro h; exact absurd (Finset.mem_univ i) h

/-- A diagonal form with entries in `[m, M]` is spectrally sandwiched by
`m` and `M`. -/
lemma hasSpectralBounds_diagonal {d : Fin n → ℝ} {m M : ℝ} (hm : ∀ i, m ≤ d i)
    (hM : ∀ i, d i ≤ M) : HasSpectralBounds (Matrix.diagonal d) m M := by
  intro x
  rw [QF_diagonal]
  constructor
  · rw [sqNorm, Finset.mul_sum]
    exact Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_right (hm i) (sq_nonneg _)
  · rw [sqNorm, Finset.mul_sum]
    exact Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_right (hM i) (sq_nonneg _)

/-- The sum-of-squares form is the identity instance, with `m = M = 1`. -/
lemma hasSpectralBounds_one : HasSpectralBounds (1 : Matrix (Fin n) (Fin n) ℝ) 1 1 := by
  have h : (1 : Matrix (Fin n) (Fin n) ℝ) = Matrix.diagonal (fun _ => (1 : ℝ)) := by
    simp [Matrix.diagonal_one]
  rw [h]
  exact hasSpectralBounds_diagonal (fun _ => le_rfl) (fun _ => le_rfl)

/-! ## Lattice reduction estimates -/

lemma distZ_nonneg (u : ℝ) : 0 ≤ distZ u := by
  have h1 := Int.fract_nonneg u
  have h2 := Int.fract_lt_one u
  simp only [distZ, le_min_iff]
  constructor <;> linarith

/-- **Lattice reduction, one coordinate.**  `distZ u` really is the distance
from `u` to the nearest integer. -/
lemma distZ_le_abs_sub (u : ℝ) (k : ℤ) : distZ u ≤ |u - k| := by
  have hf := Int.fract_nonneg u
  have hf1 := Int.fract_lt_one u
  have hfl : (⌊u⌋ : ℝ) + Int.fract u = u := Int.floor_add_fract u
  rcases le_or_gt k ⌊u⌋ with h | h
  · have hk : ((k : ℝ)) ≤ (⌊u⌋ : ℝ) := by exact_mod_cast h
    refine le_abs.mpr (Or.inl (le_trans (min_le_left _ _) ?_))
    linarith
  · have hk : ((⌊u⌋ : ℝ)) + 1 ≤ (k : ℝ) := by exact_mod_cast h
    refine le_abs.mpr (Or.inr (le_trans (min_le_right _ _) ?_))
    linarith

lemma sq_distZ_le_sq_sub (u : ℝ) (k : ℤ) : (distZ u) ^ 2 ≤ (u - k) ^ 2 := by
  have h := distZ_le_abs_sub u k
  have h0 := distZ_nonneg u
  calc (distZ u) ^ 2 ≤ |u - k| ^ 2 := by nlinarith
    _ = (u - k) ^ 2 := sq_abs _

lemma distZ_pos_of_fract_ne_zero {u : ℝ} (h : Int.fract u ≠ 0) : 0 < distZ u := by
  have h1 := Int.fract_nonneg u
  have h2 := Int.fract_lt_one u
  simp only [distZ, lt_min_iff]
  exact ⟨lt_of_le_of_ne h1 (Ne.symm h), by linarith⟩

lemma sqDistLattice_nonneg (t : Fin n → ℝ) : 0 ≤ sqDistLattice t :=
  Finset.sum_nonneg fun _ _ => sq_nonneg _

/-- **Lattice reduction bound.**  The squared distance from the shift to the
lattice is at most the squared displacement of any integer point. -/
lemma sqDistLattice_le_sqNorm_sub (t : Fin n → ℝ) (x : Fin n → ℤ) :
    sqDistLattice t ≤ sqNorm (fun i => (x i : ℝ) - t i) := by
  refine Finset.sum_le_sum fun i _ => ?_
  have h := sq_distZ_le_sq_sub (t i) (x i)
  have h2 : ((x i : ℝ) - t i) ^ 2 = (t i - (x i : ℝ)) ^ 2 := by ring
  rw [h2]
  exact h

lemma sqDistLattice_pos_of_not_mem {t : Fin n → ℝ} (i : Fin n) (h : Int.fract (t i) ≠ 0) :
    0 < sqDistLattice t :=
  Finset.sum_pos' (fun _ _ => sq_nonneg _)
    ⟨i, Finset.mem_univ i, pow_pos (distZ_pos_of_fract_ne_zero h) 2⟩

/-! ## The spectral gap -/

variable {A : Matrix (Fin n) (Fin n) ℝ} {m M : ℝ} {t : Fin n → ℝ}

/-- **Spectral gap lower bound.**  Every integer point has non-homogeneous value
at least `m` times the squared lattice distance of the shift. -/
theorem spectral_gap_lower (hA : HasSpectralBounds A m M) (hm : 0 ≤ m) (t : Fin n → ℝ)
    (x : Fin n → ℤ) : m * sqDistLattice t ≤ inhomEval A t x :=
  le_trans (mul_le_mul_of_nonneg_left (sqDistLattice_le_sqNorm_sub t x) hm)
    (hA (fun i => (x i : ℝ) - t i)).1

/-- **Strict positivity of the gap** for a shift off the lattice. -/
theorem spectral_gap_pos (hA : HasSpectralBounds A m M) (hm : 0 < m) (i : Fin n)
    (h : Int.fract (t i) ≠ 0) (x : Fin n → ℤ) : 0 < inhomEval A t x :=
  lt_of_lt_of_le (mul_pos hm (sqDistLattice_pos_of_not_mem i h))
    (spectral_gap_lower hA hm.le t x)

/-- **Diophantine obstruction.**  No integer solution exists below the spectral
gap. -/
theorem no_integer_solution_below_gap (hA : HasSpectralBounds A m M) (hm : 0 ≤ m)
    {c : ℝ} (hc : c < m * sqDistLattice t) (x : Fin n → ℤ) : inhomEval A t x ≠ c := by
  intro h
  exact absurd (h ▸ spectral_gap_lower hA hm t x) (not_le.mpr hc)

/-- The half-integral shift is the extremal case: the gap is `m·n/4`. -/
theorem gap_half_shift (hA : HasSpectralBounds A m M) (hm : 0 ≤ m)
    (t : Fin n → ℝ) (ht : ∀ i, Int.fract (t i) = 1 / 2) (x : Fin n → ℤ) :
    m * (n / 4) ≤ inhomEval A t x := by
  have hd : sqDistLattice t = (n : ℝ) / 4 := by
    simp only [sqDistLattice, distZ, ht]
    norm_num
    ring
  rw [← hd]
  exact spectral_gap_lower hA hm t x

/-! ## Covering: the matching upper bound -/

/-- **Rounding bound (covering radius).**  Some integer point has
non-homogeneous value at most `M·n/4`. -/
theorem exists_le_covering (hA : HasSpectralBounds A m M) (hM : 0 ≤ M) (t : Fin n → ℝ) :
    ∃ x : Fin n → ℤ, inhomEval A t x ≤ M * (n / 4) := by
  refine ⟨fun i => round (t i), le_trans (hA _).2 ?_⟩
  refine mul_le_mul_of_nonneg_left ?_ hM
  have hb : sqNorm (fun i => ((round (t i) : ℤ) : ℝ) - t i) ≤ ∑ _i : Fin n, (1 / 4 : ℝ) := by
    refine Finset.sum_le_sum fun i _ => ?_
    have h : |t i - round (t i)| ≤ 1 / 2 := abs_sub_round (t i)
    have h2 : (((round (t i) : ℤ) : ℝ) - t i) ^ 2 = (t i - (round (t i) : ℤ)) ^ 2 := by ring
    rw [h2, ← sq_abs]
    nlinarith [abs_nonneg (t i - ((round (t i) : ℤ) : ℝ))]
  calc sqNorm (fun i => ((round (t i) : ℤ) : ℝ) - t i) ≤ ∑ _i : Fin n, (1 / 4 : ℝ) := hb
    _ = (n : ℝ) / 4 := by simp; ring

/-- The inhomogeneous minimum of the shifted form. -/
noncomputable def inhomMin (A : Matrix (Fin n) (Fin n) ℝ) (t : Fin n → ℝ) : ℝ :=
  ⨅ x : Fin n → ℤ, inhomEval A t x

/-- **Spectral sandwich for the inhomogeneous minimum.**  The inhomogeneous
minimum is trapped between the spectral gap and the covering bound. -/
theorem inhomMin_sandwich (hA : HasSpectralBounds A m M) (hm : 0 ≤ m) (hM : 0 ≤ M)
    (t : Fin n → ℝ) :
    m * sqDistLattice t ≤ inhomMin A t ∧ inhomMin A t ≤ M * (n / 4) := by
  have hbdd : BddBelow (Set.range fun x : Fin n → ℤ => inhomEval A t x) :=
    ⟨m * sqDistLattice t, by rintro y ⟨x, rfl⟩; exact spectral_gap_lower hA hm t x⟩
  refine ⟨le_ciInf fun x => spectral_gap_lower hA hm t x, ?_⟩
  obtain ⟨x, hx⟩ := exists_le_covering hA hM t
  exact le_trans (ciInf_le hbdd x) hx

/-! ## Counting integer solutions -/

/-- Coordinatewise bound for a solution of `Q(x - t) ≤ R`. -/
lemma abs_coord_le_of_le (hA : HasSpectralBounds A m M) (hm : 0 < m) {R : ℝ}
    {x : Fin n → ℤ} (hx : inhomEval A t x ≤ R) (i : Fin n) :
    |(x i : ℝ) - t i| ≤ Real.sqrt (R / m) := by
  have h1 : m * sqNorm (fun j => (x j : ℝ) - t j) ≤ R := le_trans (hA _).1 hx
  have h2 : ((x i : ℝ) - t i) ^ 2 ≤ sqNorm (fun j => (x j : ℝ) - t j) :=
    Finset.single_le_sum (f := fun j => ((x j : ℝ) - t j) ^ 2) (fun j _ => sq_nonneg _)
      (Finset.mem_univ i)
  have h3 : ((x i : ℝ) - t i) ^ 2 ≤ R / m := by
    rw [le_div_iff₀ hm]; nlinarith
  calc |(x i : ℝ) - t i| = Real.sqrt (((x i : ℝ) - t i) ^ 2) := (Real.sqrt_sq_eq_abs _).symm
    _ ≤ Real.sqrt (R / m) := Real.sqrt_le_sqrt h3

/-- **Counting bound.**  Any finite set of integer solutions of `Q(x - t) ≤ R`
has at most `(2√(R/m) + 1)ⁿ` elements: the representation numbers of the
non-homogeneous form grow at most polynomially. -/
theorem card_solutions_le (hA : HasSpectralBounds A m M) (hm : 0 < m) {R : ℝ}
    (S : Finset (Fin n → ℤ)) (hS : ∀ x ∈ S, inhomEval A t x ≤ R) :
    (S.card : ℝ) ≤ (2 * Real.sqrt (R / m) + 1) ^ n := by
  set r := Real.sqrt (R / m) with hrdef
  have hr0 : 0 ≤ r := Real.sqrt_nonneg _
  have hsub : S ⊆ Fintype.piFinset (fun i => Finset.Icc ⌈t i - r⌉ ⌊t i + r⌋) := by
    intro x hx
    rw [Fintype.mem_piFinset]
    intro i
    have h := abs_coord_le_of_le hA hm (hS x hx) i
    rw [abs_le] at h
    exact Finset.mem_Icc.mpr
      ⟨Int.ceil_le.mpr (by linarith [h.1]), Int.le_floor.mpr (by linarith [h.2])⟩
  have hcard : (S.card : ℝ)
      ≤ ((Fintype.piFinset (fun i => Finset.Icc ⌈t i - r⌉ ⌊t i + r⌋)).card : ℝ) := by
    exact_mod_cast Finset.card_le_card hsub
  refine hcard.trans ?_
  rw [Fintype.card_piFinset]
  push_cast
  have hstep : ∀ i : Fin n, ((Finset.Icc ⌈t i - r⌉ ⌊t i + r⌋).card : ℝ) ≤ 2 * r + 1 := by
    intro i
    rw [Int.card_Icc]
    have hz : ((⌊t i + r⌋ + 1 - ⌈t i - r⌉ : ℤ) : ℝ) ≤ 2 * r + 1 := by
      have h1 : ((⌊t i + r⌋ : ℤ) : ℝ) ≤ t i + r := Int.floor_le _
      have h2 : t i - r ≤ ((⌈t i - r⌉ : ℤ) : ℝ) := Int.le_ceil _
      push_cast
      linarith
    rcases le_or_gt (⌊t i + r⌋ + 1 - ⌈t i - r⌉) 0 with h | h
    · rw [Int.toNat_of_nonpos h]
      push_cast
      linarith
    · have hcast := Int.toNat_of_nonneg h.le
      calc (((⌊t i + r⌋ + 1 - ⌈t i - r⌉).toNat : ℕ) : ℝ)
          = ((⌊t i + r⌋ + 1 - ⌈t i - r⌉ : ℤ) : ℝ) := by
            exact_mod_cast congrArg (fun z : ℤ => (z : ℝ)) hcast
        _ ≤ 2 * r + 1 := hz
  calc ∏ i : Fin n, ((Finset.Icc ⌈t i - r⌉ ⌊t i + r⌋).card : ℝ)
      ≤ ∏ _i : Fin n, (2 * r + 1) :=
        Finset.prod_le_prod (fun i _ => by positivity) (fun i _ => hstep i)
    _ = (2 * r + 1) ^ n := by simp

/-! ## The inhomogeneous theta series -/

/-- One-dimensional Gaussian summability over `ℕ`. -/
lemma summable_nat_gauss (c a : ℝ) (hc : 0 < c) :
    Summable (fun k : ℕ => Real.exp (-(c * ((k : ℝ) - a) ^ 2))) := by
  have hgeom : Summable (fun k : ℕ =>
      Real.exp (c * ((2 * a + 1) ^ 2 / 4)) * Real.exp ((k : ℝ) * (-c))) :=
    (Real.summable_exp_nat_mul_iff.mpr (by linarith : -c < 0)).mul_left _
  refine hgeom.of_nonneg_of_le (fun k => (Real.exp_pos _).le) (fun k => ?_)
  rw [← Real.exp_add]
  refine Real.exp_le_exp.mpr ?_
  have key : (k : ℝ) - (2 * a + 1) ^ 2 / 4 ≤ ((k : ℝ) - a) ^ 2 := by
    nlinarith [sq_nonneg ((k : ℝ) - (2 * a + 1) / 2), sq_nonneg a]
  nlinarith [mul_le_mul_of_nonneg_left key hc.le]

/-- One-dimensional Gaussian summability over `ℤ`: the classical (shifted)
Jacobi theta series converges. -/
lemma summable_int_gauss (c a : ℝ) (hc : 0 < c) :
    Summable (fun k : ℤ => Real.exp (-(c * ((k : ℝ) - a) ^ 2))) := by
  rw [summable_int_iff_summable_nat_and_neg]
  refine ⟨by simpa using summable_nat_gauss c a hc, ?_⟩
  refine (summable_nat_gauss c (-a) hc).congr (fun k => ?_)
  push_cast
  ring_nf

/-- The tuple-splitting equivalence `ℤ × ℤⁿ ≃ ℤⁿ⁺¹`. -/
def consEquivZ (n : ℕ) : ℤ × (Fin n → ℤ) ≃ (Fin (n + 1) → ℤ) where
  toFun p := Fin.cons p.1 p.2
  invFun x := (x 0, Fin.tail x)
  left_inv p := by simp [Fin.tail_cons]
  right_inv x := by simp [Fin.cons_self_tail]

set_option maxHeartbeats 1000000 in
/-- Summability of a product of one-dimensional summable non-negative families
over the lattice `ℤⁿ` (induction on the rank via `consEquivZ`). -/
lemma summable_pi_prod : ∀ (n : ℕ) (f : Fin n → ℤ → ℝ), (∀ i, Summable (f i)) →
    (∀ i k, 0 ≤ f i k) → Summable (fun x : Fin n → ℤ => ∏ i, f i (x i)) := by
  intro n
  induction n with
  | zero =>
    intro f _ _
    simp only [Finset.univ_eq_empty, Finset.prod_empty]
    exact summable_of_finite_support (Set.toFinite _)
  | succ n ih =>
    intro f hs hnn
    have h1 : Summable (f 0) := hs 0
    have h2 : Summable (fun y : Fin n → ℤ => ∏ i : Fin n, f i.succ (y i)) :=
      ih (fun i => f i.succ) (fun i => hs i.succ) (fun i k => hnn i.succ k)
    have hf' : (0 : ℤ → ℝ) ≤ f 0 := fun k => hnn 0 k
    have hg' : (0 : (Fin n → ℤ) → ℝ) ≤ fun y : Fin n → ℤ => ∏ i : Fin n, f i.succ (y i) :=
      fun y => Finset.prod_nonneg (fun i _ => hnn i.succ (y i))
    have hprod := h1.mul_of_nonneg h2 hf' hg'
    refine ((consEquivZ n).summable_iff).mp (hprod.congr (fun p => ?_))
    simp [consEquivZ, Function.comp, Fin.prod_univ_succ]

/-- The inhomogeneous theta series `Θ(s) = ∑_{x ∈ ℤⁿ} exp(-s·Q(x - t))`. -/
noncomputable def theta (A : Matrix (Fin n) (Fin n) ℝ) (t : Fin n → ℝ) (s : ℝ) : ℝ :=
  ∑' x : Fin n → ℤ, Real.exp (-(s * inhomEval A t x))

/-- **Convergence of the inhomogeneous theta series** for a positive-definite
(spectrally bounded below) form. -/
theorem summable_theta (hA : HasSpectralBounds A m M) (hm : 0 < m) (t : Fin n → ℝ)
    {s : ℝ} (hs : 0 < s) :
    Summable (fun x : Fin n → ℤ => Real.exp (-(s * inhomEval A t x))) := by
  have hmaj : Summable (fun x : Fin n → ℤ =>
      ∏ i, Real.exp (-((s * m) * ((x i : ℝ) - t i) ^ 2))) :=
    summable_pi_prod n (fun i k => Real.exp (-((s * m) * ((k : ℝ) - t i) ^ 2)))
      (fun i => summable_int_gauss (s * m) (t i) (by positivity))
      (fun i k => (Real.exp_pos _).le)
  refine Summable.of_nonneg_of_le (fun x => (Real.exp_pos _).le) (fun x => ?_) hmaj
  have h1 : m * sqNorm (fun j => (x j : ℝ) - t j) ≤ inhomEval A t x := (hA _).1
  have hsum : ∑ i, -((s * m) * ((x i : ℝ) - t i) ^ 2)
      = -(s * (m * sqNorm (fun j => (x j : ℝ) - t j))) := by
    calc ∑ i, -((s * m) * ((x i : ℝ) - t i) ^ 2)
        = ∑ i, (-(s * m)) * ((x i : ℝ) - t i) ^ 2 :=
          Finset.sum_congr rfl (fun i _ => by ring)
      _ = (-(s * m)) * ∑ i, ((x i : ℝ) - t i) ^ 2 := (Finset.mul_sum _ _ _).symm
      _ = -(s * (m * sqNorm (fun j => (x j : ℝ) - t j))) := by rw [sqNorm]; ring
  have hprod : ∏ i, Real.exp (-((s * m) * ((x i : ℝ) - t i) ^ 2))
      = Real.exp (-(s * (m * sqNorm (fun j => (x j : ℝ) - t j)))) := by
    rw [← hsum, Real.exp_sum]
  rw [hprod]
  exact Real.exp_le_exp.mpr (by nlinarith)

/-- **Lower bound for the theta series** coming from the covering estimate:
the theta series is never smaller than the contribution of the rounded point. -/
theorem theta_ge (hA : HasSpectralBounds A m M) (hm : 0 < m) (hM : 0 ≤ M) (t : Fin n → ℝ)
    {s : ℝ} (hs : 0 < s) : Real.exp (-(s * (M * (n / 4)))) ≤ theta A t s := by
  obtain ⟨x₀, hx₀⟩ := exists_le_covering hA hM t
  have hsum := summable_theta hA hm t hs
  have h1 : Real.exp (-(s * (M * (n / 4)))) ≤ Real.exp (-(s * inhomEval A t x₀)) :=
    Real.exp_le_exp.mpr (by nlinarith [mul_le_mul_of_nonneg_left hx₀ hs.le])
  exact h1.trans (hsum.le_tsum x₀ (fun j _ => (Real.exp_pos _).le))

/-- **Exponential decay of the theta series at the spectral-gap rate.**
The gap `m·d(t,ℤⁿ)²` is exactly the exponential rate at which the
non-homogeneous theta series decays. -/
theorem theta_decay (hA : HasSpectralBounds A m M) (hm : 0 < m) (t : Fin n → ℝ)
    {s₀ s : ℝ} (hs₀ : 0 < s₀) (hss : s₀ ≤ s) :
    theta A t s ≤ Real.exp (-((s - s₀) * (m * sqDistLattice t))) * theta A t s₀ := by
  have hsum0 := summable_theta hA hm t hs₀
  have hsums := summable_theta hA hm t (lt_of_lt_of_le hs₀ hss)
  have hmaj : Summable (fun x : Fin n → ℤ =>
      Real.exp (-((s - s₀) * (m * sqDistLattice t))) * Real.exp (-(s₀ * inhomEval A t x))) :=
    hsum0.mul_left _
  have hterm : ∀ x : Fin n → ℤ, Real.exp (-(s * inhomEval A t x))
      ≤ Real.exp (-((s - s₀) * (m * sqDistLattice t))) * Real.exp (-(s₀ * inhomEval A t x)) := by
    intro x
    rw [← Real.exp_add]
    refine Real.exp_le_exp.mpr ?_
    have hg := spectral_gap_lower hA hm.le t x
    nlinarith [mul_le_mul_of_nonneg_left hg (sub_nonneg.mpr hss)]
  calc theta A t s
      ≤ ∑' x : Fin n → ℤ, Real.exp (-((s - s₀) * (m * sqDistLattice t)))
          * Real.exp (-(s₀ * inhomEval A t x)) := Summable.tsum_le_tsum hterm hsums hmaj
    _ = Real.exp (-((s - s₀) * (m * sqDistLattice t))) * theta A t s₀ :=
        hsum0.tsum_mul_left _

/-! ## A concrete Diophantine corollary -/

/-- **Half-shifted sum of squares.**  For every integer vector `x ∈ ℤⁿ`,
`∑ᵢ (xᵢ - 1/2)² ≥ n/4`; in particular the non-homogeneous equation
`∑ᵢ (xᵢ - 1/2)² = c` has no integer solution for `c < n/4`. -/
theorem sum_sq_half_shift_ge (x : Fin n → ℤ) :
    (n : ℝ) / 4 ≤ ∑ i, ((x i : ℝ) - 1 / 2) ^ 2 := by
  have hfract : ∀ i : Fin n, Int.fract ((fun _ : Fin n => (1 / 2 : ℝ)) i) = 1 / 2 := by
    intro i
    exact Int.fract_eq_self.mpr ⟨by norm_num, by norm_num⟩
  have h := gap_half_shift (A := (1 : Matrix (Fin n) (Fin n) ℝ)) (m := 1) (M := 1)
    hasSpectralBounds_one zero_le_one (fun _ => (1 / 2 : ℝ)) hfract x
  have hQ : inhomEval (1 : Matrix (Fin n) (Fin n) ℝ) (fun _ => (1 / 2 : ℝ)) x
      = ∑ i, ((x i : ℝ) - 1 / 2) ^ 2 := by
    have h1 : (1 : Matrix (Fin n) (Fin n) ℝ) = Matrix.diagonal (fun _ => (1 : ℝ)) := by
      simp [Matrix.diagonal_one]
    rw [inhomEval, h1, QF_diagonal]
    exact Finset.sum_congr rfl (fun i _ => by ring)
  rw [hQ] at h
  linarith

end DiophantineLattice

/-! ## Cycle II: effective rational gaps, factorisation, and decay to zero

The results above are "soft": the gap is controlled by the (real) distance from
the shift to the lattice.  The next block makes the gap *effective* for rational
shifts, factorises the theta series of a diagonal form into one-dimensional
Jacobi theta factors, and turns the decay estimate into a genuine limit.
-/

namespace DiophantineLattice.Cycle2

variable {n : ℕ} {A : Matrix (Fin n) (Fin n) ℝ} {m M : ℝ} {t : Fin n → ℝ}

/-- **Effective distance bound at a rational point.**  If `q ∤ a` then `a/q` is
at distance at least `1/q` from `ℤ`. -/
lemma distZ_rat_ge {a q : ℤ} (hq : 0 < q) (h : ¬ (q ∣ a)) :
    1 / (q : ℝ) ≤ distZ ((a : ℝ) / q) := by
  have hq0 : (0 : ℝ) < (q : ℝ) := by exact_mod_cast hq
  obtain ⟨L, hL⟩ : ∃ L : ℤ, L = ⌊(a : ℝ) / q⌋ := ⟨_, rfl⟩
  have hfr : Int.fract ((a : ℝ) / q) = ((a - q * L : ℤ) : ℝ) / q := by
    rw [Int.fract, ← hL]
    push_cast
    field_simp
  have h0 : (0 : ℝ) ≤ ((a - q * L : ℤ) : ℝ) / q := hfr ▸ Int.fract_nonneg _
  have h1 : ((a - q * L : ℤ) : ℝ) / q < 1 := hfr ▸ Int.fract_lt_one _
  have hr0 : (0 : ℝ) ≤ ((a - q * L : ℤ) : ℝ) := by
    by_contra hcon
    push_neg at hcon
    exact absurd h0 (not_le.mpr (div_neg_of_neg_of_pos hcon hq0))
  have hrq : ((a - q * L : ℤ) : ℝ) < (q : ℝ) := by
    rw [div_lt_one hq0] at h1; exact h1
  have hr0' : 0 ≤ a - q * L := by exact_mod_cast hr0
  have hrq' : a - q * L < q := by exact_mod_cast hrq
  have hrne : a - q * L ≠ 0 := by
    intro hzero
    exact h ⟨L, by omega⟩
  have h1r : (1 : ℝ) ≤ ((a - q * L : ℤ) : ℝ) := by
    exact_mod_cast (by omega : (1 : ℤ) ≤ a - q * L)
  have hrle : ((a - q * L : ℤ) : ℝ) + 1 ≤ (q : ℝ) := by
    exact_mod_cast (by omega : a - q * L + 1 ≤ q)
  simp only [distZ, le_min_iff, hfr]
  constructor
  · have hk : ((a - q * L : ℤ) : ℝ) / q - 1 / q = (((a - q * L : ℤ) : ℝ) - 1) / q := by ring
    have hpos := div_nonneg (by linarith : (0 : ℝ) ≤ ((a - q * L : ℤ) : ℝ) - 1) hq0.le
    linarith
  · have hk : 1 - ((a - q * L : ℤ) : ℝ) / q - 1 / q
        = ((q : ℝ) - ((a - q * L : ℤ) : ℝ) - 1) / q := by field_simp
    have hpos := div_nonneg
      (by linarith : (0 : ℝ) ≤ (q : ℝ) - ((a - q * L : ℤ) : ℝ) - 1) hq0.le
    linarith

/-- **Effective spectral gap for a rational shift.**  If the shift has all
coordinates in `(1/q)ℤ` and at least one coordinate is not an integer, then the
non-homogeneous form is bounded below by `m/q²` on the whole lattice. -/
theorem gap_rational_shift (hA : HasSpectralBounds A m M) (hm : 0 ≤ m) {q : ℤ} (hq : 0 < q)
    (a : Fin n → ℤ) (ht : ∀ i, t i = (a i : ℝ) / q) {i₀ : Fin n} (hdvd : ¬ (q ∣ a i₀))
    (x : Fin n → ℤ) : m / (q : ℝ) ^ 2 ≤ inhomEval A t x := by
  have hq0 : (0 : ℝ) < (q : ℝ) := by exact_mod_cast hq
  have h1 : 1 / (q : ℝ) ≤ distZ (t i₀) := by
    rw [ht i₀]; exact distZ_rat_ge hq hdvd
  have h2 : (1 / (q : ℝ)) ^ 2 ≤ (distZ (t i₀)) ^ 2 := by
    nlinarith [distZ_nonneg (t i₀), one_div_pos.mpr hq0]
  have hd : 1 / (q : ℝ) ^ 2 ≤ sqDistLattice t := by
    calc 1 / (q : ℝ) ^ 2 = (1 / (q : ℝ)) ^ 2 := by ring
      _ ≤ (distZ (t i₀)) ^ 2 := h2
      _ ≤ sqDistLattice t :=
        Finset.single_le_sum (f := fun j => (distZ (t j)) ^ 2)
          (fun j _ => sq_nonneg _) (Finset.mem_univ i₀)
  calc m / (q : ℝ) ^ 2 = m * (1 / (q : ℝ) ^ 2) := by ring
    _ ≤ m * sqDistLattice t := mul_le_mul_of_nonneg_left hd hm
    _ ≤ inhomEval A t x := spectral_gap_lower hA hm t x

/-- **Effective Diophantine obstruction at rational shifts.**  For `c < m/q²`
the equation `Q(x - a/q) = c` has no integer solution. -/
theorem no_solution_rational_shift (hA : HasSpectralBounds A m M) (hm : 0 ≤ m) {q : ℤ}
    (hq : 0 < q) (a : Fin n → ℤ) (ht : ∀ i, t i = (a i : ℝ) / q) {i₀ : Fin n}
    (hdvd : ¬ (q ∣ a i₀)) {c : ℝ} (hc : c < m / (q : ℝ) ^ 2) (x : Fin n → ℤ) :
    inhomEval A t x ≠ c := by
  intro hx
  exact absurd (hx ▸ gap_rational_shift hA hm hq a ht hdvd x) (not_le.mpr hc)

/-- **Solvability window.**  Above the covering bound the inequality
`Q(x - t) ≤ R` is always solvable; below the spectral gap it never is. -/
theorem solvability_window (hA : HasSpectralBounds A m M) (hm : 0 ≤ m) (hM : 0 ≤ M)
    (t : Fin n → ℝ) :
    (∀ R : ℝ, M * (n / 4) ≤ R → ∃ x : Fin n → ℤ, inhomEval A t x ≤ R) ∧
      (∀ R : ℝ, R < m * sqDistLattice t → ¬ ∃ x : Fin n → ℤ, inhomEval A t x ≤ R) := by
  constructor
  · intro R hR
    obtain ⟨x, hx⟩ := exists_le_covering hA hM t
    exact ⟨x, hx.trans hR⟩
  · rintro R hR ⟨x, hx⟩
    exact absurd (le_trans (spectral_gap_lower hA hm t x) hx) (not_le.mpr hR)

set_option maxHeartbeats 1000000 in
/-- **Fubini for lattice products.**  The sum over `ℤⁿ` of a product of
one-dimensional non-negative summable families factorises. -/
lemma tsum_pi_prod : ∀ (n : ℕ) (f : Fin n → ℤ → ℝ), (∀ i, Summable (f i)) →
    (∀ i k, 0 ≤ f i k) →
    ∑' x : Fin n → ℤ, ∏ i, f i (x i) = ∏ i, ∑' k : ℤ, f i k := by
  intro n
  induction n with
  | zero =>
    intro f _ _
    simp only [Finset.univ_eq_empty, Finset.prod_empty]
    rw [tsum_const]
    simp
  | succ n ih =>
    intro f hs hnn
    have h1 : Summable (f 0) := hs 0
    have h2 : Summable (fun y : Fin n → ℤ => ∏ i : Fin n, f i.succ (y i)) :=
      summable_pi_prod n (fun i => f i.succ) (fun i => hs i.succ) (fun i k => hnn i.succ k)
    have hf' : (0 : ℤ → ℝ) ≤ f 0 := fun k => hnn 0 k
    have hg' : (0 : (Fin n → ℤ) → ℝ) ≤ fun y : Fin n → ℤ => ∏ i : Fin n, f i.succ (y i) :=
      fun y => Finset.prod_nonneg (fun i _ => hnn i.succ (y i))
    have hprod := h1.mul_of_nonneg h2 hf' hg'
    have key : ∑' x : Fin (n + 1) → ℤ, ∏ i, f i (x i)
        = ∑' p : ℤ × (Fin n → ℤ), f 0 p.1 * ∏ i : Fin n, f i.succ (p.2 i) := by
      rw [← (consEquivZ n).tsum_eq (fun x : Fin (n + 1) → ℤ => ∏ i, f i (x i))]
      exact tsum_congr (fun p => by simp [consEquivZ, Fin.prod_univ_succ])
    rw [key, ← h1.tsum_mul_tsum h2 hprod,
      ih (fun i => f i.succ) (fun i => hs i.succ) (fun i k => hnn i.succ k),
      Fin.prod_univ_succ]

/-- **Theta factorisation for diagonal forms.**  The `n`-dimensional
inhomogeneous theta series of a diagonal positive form is the product of `n`
one-dimensional shifted Jacobi theta values. -/
theorem theta_diagonal {d : Fin n → ℝ} (hd : ∀ i, 0 < d i) (t : Fin n → ℝ) {s : ℝ}
    (hs : 0 < s) :
    theta (Matrix.diagonal d) t s
      = ∏ i, ∑' k : ℤ, Real.exp (-((s * d i) * ((k : ℝ) - t i) ^ 2)) := by
  have hterm : ∀ x : Fin n → ℤ, Real.exp (-(s * inhomEval (Matrix.diagonal d) t x))
      = ∏ i, Real.exp (-((s * d i) * ((x i : ℝ) - t i) ^ 2)) := by
    intro x
    have hsum : ∑ i, -((s * d i) * ((x i : ℝ) - t i) ^ 2)
        = -(s * ∑ i, d i * ((x i : ℝ) - t i) ^ 2) := by
      calc ∑ i, -((s * d i) * ((x i : ℝ) - t i) ^ 2)
          = ∑ i, (-s) * (d i * ((x i : ℝ) - t i) ^ 2) :=
            Finset.sum_congr rfl (fun i _ => by ring)
        _ = (-s) * ∑ i, d i * ((x i : ℝ) - t i) ^ 2 := (Finset.mul_sum _ _ _).symm
        _ = -(s * ∑ i, d i * ((x i : ℝ) - t i) ^ 2) := by ring
    rw [inhomEval, QF_diagonal, ← Real.exp_sum, hsum]
  rw [theta, tsum_congr hterm]
  exact tsum_pi_prod n (fun i k => Real.exp (-((s * d i) * ((k : ℝ) - t i) ^ 2)))
    (fun i => summable_int_gauss (s * d i) (t i) (mul_pos hs (hd i)))
    (fun i k => (Real.exp_pos _).le)

/-- **Theta series vanishes at infinity when the gap is positive.**  If the
shift is off the lattice, `Θ(s) → 0` as `s → ∞` — the analytic shadow of the
non-solvability of `Q(x - t) = 0`. -/
theorem theta_tendsto_zero (hA : HasSpectralBounds A m M) (hm : 0 < m) (t : Fin n → ℝ)
    (i : Fin n) (hfract : Int.fract (t i) ≠ 0) :
    Filter.Tendsto (fun s : ℝ => theta A t s) Filter.atTop (nhds 0) := by
  have hg : 0 < m * sqDistLattice t := mul_pos hm (sqDistLattice_pos_of_not_mem i hfract)
  have hlin : Filter.Tendsto
      (fun s : ℝ => -((s - 1) * (m * sqDistLattice t))) Filter.atTop Filter.atBot := by
    have h1 : Filter.Tendsto (fun s : ℝ => s - 1) Filter.atTop Filter.atTop :=
      Filter.tendsto_atTop_add_const_right _ (-1) Filter.tendsto_id
    exact Filter.tendsto_neg_atTop_atBot.comp (h1.atTop_mul_const hg)
  have hmaj : Filter.Tendsto
      (fun s : ℝ => Real.exp (-((s - 1) * (m * sqDistLattice t))) * theta A t 1)
      Filter.atTop (nhds 0) := by
    simpa using (Real.tendsto_exp_atBot.comp hlin).mul_const (theta A t 1)
  refine squeeze_zero' ?_ ?_ hmaj
  · filter_upwards with s
    exact tsum_nonneg (fun x => (Real.exp_pos _).le)
  · filter_upwards [Filter.eventually_ge_atTop (1 : ℝ)] with s hs
    exact theta_decay hA hm t one_pos hs

end DiophantineLattice.Cycle2

/-! ## Cycle III: a matching lower bound for the counting function

`card_solutions_le` bounds the number of solutions of `Q(x - t) ≤ R` from above
by `(2√(R/m) + 1)ⁿ`.  Beyond the covering threshold `R ≥ M·n/4` there is a
matching lower bound `(2√(R/(M·n)) - 1)ⁿ`, so the counting function of a
spectrally sandwiched non-homogeneous form grows exactly like `Rⁿ/²`.
-/

namespace DiophantineLattice.Cycle3

variable {n : ℕ} {A : Matrix (Fin n) (Fin n) ℝ} {m M : ℝ} {t : Fin n → ℝ}

/-- **Many solutions above the covering threshold.**  For `R ≥ M·n/4` there is a
finite set of integer solutions of `Q(x - t) ≤ R` of cardinality at least
`(2√(R/(M·n)) - 1)ⁿ`. -/
theorem exists_many_solutions (hA : HasSpectralBounds A m M) (hM : 0 < M) (hn : 0 < n)
    {R : ℝ} (hR : M * ((n : ℝ) / 4) ≤ R) :
    ∃ S : Finset (Fin n → ℤ), (∀ x ∈ S, inhomEval A t x ≤ R) ∧
      (2 * Real.sqrt (R / (M * n)) - 1) ^ n ≤ (S.card : ℝ) := by
  have hn0 : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  have hMn : (0 : ℝ) < M * n := mul_pos hM hn0
  have hR0 : 0 ≤ R := le_trans (by positivity) hR
  have hquot : (1 : ℝ) / 4 ≤ R / (M * n) := by
    rw [le_div_iff₀ hMn]
    linarith [hR]
  set p : ℝ := Real.sqrt (R / (M * n)) with hp
  have hp2 : p ^ 2 = R / (M * n) := Real.sq_sqrt (by positivity)
  have hphalf : (1 : ℝ) / 2 ≤ p := by
    have h4 : Real.sqrt (1 / 4) ≤ p := Real.sqrt_le_sqrt hquot
    have : Real.sqrt (1 / 4) = 1 / 2 := by
      rw [show (1 / 4 : ℝ) = (1 / 2) ^ 2 by norm_num, Real.sqrt_sq (by norm_num)]
    linarith [this ▸ h4]
  refine ⟨Fintype.piFinset (fun i => Finset.Icc ⌈t i - p⌉ ⌊t i + p⌋), ?_, ?_⟩
  · intro x hx
    rw [Fintype.mem_piFinset] at hx
    have hcoord : ∀ i, ((x i : ℝ) - t i) ^ 2 ≤ p ^ 2 := by
      intro i
      obtain ⟨h1, h2⟩ := Finset.mem_Icc.mp (hx i)
      have hlo : t i - p ≤ (x i : ℝ) := by
        have hc : ((⌈t i - p⌉ : ℤ) : ℝ) ≤ (x i : ℝ) := by exact_mod_cast h1
        linarith [Int.le_ceil (t i - p)]
      have hhi : (x i : ℝ) ≤ t i + p := le_trans (by exact_mod_cast h2) (Int.floor_le _)
      nlinarith
    have hnorm : sqNorm (fun i => (x i : ℝ) - t i) ≤ (n : ℝ) * p ^ 2 := by
      calc sqNorm (fun i => (x i : ℝ) - t i) ≤ ∑ _i : Fin n, p ^ 2 :=
            Finset.sum_le_sum (fun i _ => hcoord i)
        _ = (n : ℝ) * p ^ 2 := by simp
    have hMnn : M * ((n : ℝ) * p ^ 2) = R := by
      rw [hp2]
      field_simp
    calc inhomEval A t x ≤ M * sqNorm (fun i => (x i : ℝ) - t i) := (hA _).2
      _ ≤ M * ((n : ℝ) * p ^ 2) := mul_le_mul_of_nonneg_left hnorm hM.le
      _ = R := hMnn
  · rw [Fintype.card_piFinset]
    push_cast
    have hstep : ∀ i : Fin n, 2 * p - 1 ≤ ((Finset.Icc ⌈t i - p⌉ ⌊t i + p⌋).card : ℝ) := by
      intro i
      rw [Int.card_Icc]
      have h1 : (t i + p) - 1 < ((⌊t i + p⌋ : ℤ) : ℝ) := Int.sub_one_lt_floor _
      have h2 : ((⌈t i - p⌉ : ℤ) : ℝ) < (t i - p) + 1 := Int.ceil_lt_add_one _
      have hz : 2 * p - 1 < ((⌊t i + p⌋ + 1 - ⌈t i - p⌉ : ℤ) : ℝ) := by
        push_cast
        linarith
      have hz0 : 0 ≤ ⌊t i + p⌋ + 1 - ⌈t i - p⌉ := by
        by_contra hcon
        push_neg at hcon
        have : ((⌊t i + p⌋ + 1 - ⌈t i - p⌉ : ℤ) : ℝ) < 0 := by exact_mod_cast hcon
        linarith
      have hcast := Int.toNat_of_nonneg hz0
      have : (((⌊t i + p⌋ + 1 - ⌈t i - p⌉).toNat : ℕ) : ℝ)
          = ((⌊t i + p⌋ + 1 - ⌈t i - p⌉ : ℤ) : ℝ) := by
        exact_mod_cast congrArg (fun z : ℤ => (z : ℝ)) hcast
      rw [this]
      linarith
    calc (2 * p - 1) ^ n = ∏ _i : Fin n, (2 * p - 1) := by simp
      _ ≤ ∏ i : Fin n, ((Finset.Icc ⌈t i - p⌉ ⌊t i + p⌋).card : ℝ) :=
          Finset.prod_le_prod (fun i _ => by linarith) (fun i _ => hstep i)

/-- **Two-sided counting for the non-homogeneous form.**  Beyond the covering
threshold the number of integer solutions of `Q(x - t) ≤ R` is trapped between
`(2√(R/(M·n)) - 1)ⁿ` and `(2√(R/m) + 1)ⁿ`. -/
theorem counting_two_sided (hA : HasSpectralBounds A m M) (hm : 0 < m) (hM : 0 < M)
    (hn : 0 < n) {R : ℝ} (hR : M * ((n : ℝ) / 4) ≤ R) :
    ∃ S : Finset (Fin n → ℤ), (∀ x ∈ S, inhomEval A t x ≤ R) ∧
      (2 * Real.sqrt (R / (M * n)) - 1) ^ n ≤ (S.card : ℝ) ∧
      (S.card : ℝ) ≤ (2 * Real.sqrt (R / m) + 1) ^ n := by
  obtain ⟨S, hSsol, hScard⟩ := exists_many_solutions hA hM hn hR
  exact ⟨S, hSsol, hScard, card_solutions_le hA hm S hSsol⟩

end DiophantineLattice.Cycle3

/-! ## Cycle IV: exact structure of the extremal solution set

For the half-shifted sum of squares the sandwich `m·d(t,ℤⁿ)² ≤ μ ≤ M·n/4`
collapses (`m = M = 1`, `d² = n/4`), so the inhomogeneous minimum is exactly
`n/4`.  Here we determine the *whole* extremal solution set: it is the vertex
set of the unit cube, of cardinality `2ⁿ`.
-/

namespace DiophantineLattice.Cycle4

variable {n : ℕ}

/-- Each coordinate of the half-shifted sum of squares is at least `1/4`, with
equality exactly at `0` and `1`. -/
lemma quarter_le_sq_sub_half (k : ℤ) : (1 : ℝ) / 4 ≤ ((k : ℝ) - 1 / 2) ^ 2 := by
  have hk : 0 ≤ k * (k - 1) := by
    rcases le_or_gt k 0 with h | h
    · nlinarith
    · nlinarith
  have hkR : (0 : ℝ) ≤ (k : ℝ) * ((k : ℝ) - 1) := by exact_mod_cast hk
  nlinarith

lemma sq_sub_half_eq_quarter_iff {k : ℤ} :
    ((k : ℝ) - 1 / 2) ^ 2 = 1 / 4 ↔ k = 0 ∨ k = 1 := by
  constructor
  · intro h
    have hk : (k : ℝ) * ((k : ℝ) - 1) = 0 := by nlinarith
    have : k * (k - 1) = 0 := by exact_mod_cast hk
    rcases mul_eq_zero.mp this with h' | h'
    · exact Or.inl h'
    · exact Or.inr (by omega)
  · rintro (rfl | rfl) <;> norm_num

/-- **Exact extremal set.**  An integer vector satisfies
`∑ᵢ (xᵢ - 1/2)² ≤ n/4` if and only if all of its coordinates are `0` or `1`. -/
theorem half_shift_solution_iff (x : Fin n → ℤ) :
    (∑ i, ((x i : ℝ) - 1 / 2) ^ 2 ≤ (n : ℝ) / 4) ↔ ∀ i, x i = 0 ∨ x i = 1 := by
  have hconst : ∑ _i : Fin n, (1 : ℝ) / 4 = (n : ℝ) / 4 := by
    rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    ring
  have hge : ∀ i ∈ (Finset.univ : Finset (Fin n)), (1 : ℝ) / 4 ≤ ((x i : ℝ) - 1 / 2) ^ 2 :=
    fun i _ => quarter_le_sq_sub_half (x i)
  constructor
  · intro hle
    have hsumle : ∑ _i : Fin n, (1 : ℝ) / 4 ≤ ∑ i, ((x i : ℝ) - 1 / 2) ^ 2 :=
      Finset.sum_le_sum hge
    have heq : ∑ _i : Fin n, (1 : ℝ) / 4 = ∑ i, ((x i : ℝ) - 1 / 2) ^ 2 := by
      rw [hconst] at hsumle ⊢
      linarith
    have hall := (Finset.sum_eq_sum_iff_of_le hge).mp heq
    intro i
    exact sq_sub_half_eq_quarter_iff.mp (hall i (Finset.mem_univ i)).symm
  · intro hx
    have hterm : ∀ i ∈ (Finset.univ : Finset (Fin n)),
        ((x i : ℝ) - 1 / 2) ^ 2 = (1 : ℝ) / 4 :=
      fun i _ => sq_sub_half_eq_quarter_iff.mpr (hx i)
    rw [Finset.sum_congr rfl hterm, hconst]

/-- **The extremal solution set is the vertex set of the unit cube.**  It has
exactly `2ⁿ` elements, so the inhomogeneous minimum `n/4` of the half-shifted
sum of squares is attained with multiplicity `2ⁿ`. -/
theorem half_shift_minimizer_count :
    ∃ S : Finset (Fin n → ℤ),
      (∀ x : Fin n → ℤ, x ∈ S ↔ ∑ i, ((x i : ℝ) - 1 / 2) ^ 2 ≤ (n : ℝ) / 4) ∧
      S.card = 2 ^ n := by
  refine ⟨Fintype.piFinset (fun _ : Fin n => ({0, 1} : Finset ℤ)), fun x => ?_, ?_⟩
  · rw [Fintype.mem_piFinset, half_shift_solution_iff]
    exact forall_congr' (fun i => by simp)
  · rw [Fintype.card_piFinset]
    simp

end DiophantineLattice.Cycle4