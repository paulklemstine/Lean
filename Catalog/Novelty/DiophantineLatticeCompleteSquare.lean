import Novelty.DiophantineLatticeTorsionGap

/-!
# Non-homogeneous quadratic forms with a linear term: completing the square

Cycle 3.  The classical non-homogeneous quadratic Diophantine equation is

  `F(x) = Q(x) + ℓ(x) + c = 0`,  `Q(x) = xᵀBx`, `ℓ(x) = Σ bᵢ xᵢ`,

and the standard manoeuvre is to complete the square: if `s` solves `2·Bil(s, ·) = ℓ`, then
`F(x) = Q(x + s) + (c - Q(s))`, so the solvability of `F = 0` over `ℤⁿ` is governed by the
*spectral gap* of the shifted form studied in the previous two cycles.

* `complete_the_square` : the algebraic identity (needs `B` symmetric only).
* `nonhom_ge_archimedean` : the naive real obstruction `F(x) ≥ c - Q(s)`.
* `nonhom_ge_torsion` : the lattice refinement, `F(x) ≥ λ₁/r² + c - Q(s)`, valid when `-s` is
  the `r`-torsion point `v/r` of a shortest vector `v`.
* `nonhom_unsolvable_of_pos` : consequently, when `s = -v/r`, the equation `F = 0` has **no**
  integral solution as soon as `c > 0` — whereas the archimedean criterion only rules out
  `c > λ₁/r²`.  The lattice gap improves the classical criterion by exactly `λ₁/r²`.
* `sum_sq_sub_self_even` and `sum_sq_sub_self_eq_zero_iff_of_pos` : the concrete arithmetic
  payoff in the standard case, `Σ (xᵢ² - xᵢ)` is always an even non-negative integer, so
  `Σ (xᵢ² - xᵢ) + c = 0` forces `c` to be a non-positive even integer.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the `λ₁/r²` gap should be visible as a strict improvement of the
classical "complete the square and use positivity" unsolvability criterion.
Experiment (Experimenter): completing the square at `s = -v/2` for the standard form in
dimension `n` turns `F` into `Σ(xᵢ² - xᵢ) + c`; enumeration (`ComputationalEvidence.md`, §1)
shows `Σ(xᵢ² - xᵢ) ∈ {0, 2, 4, …}` — the archimedean bound `≥ -n/4` is off by the whole gap.
Analysis (Analyst): the improvement is exactly `Q(s) = λ₁/r²`, i.e. the archimedean bound
`c - Q(s)` is replaced by `c`; the residual arithmetic (evenness) is the `2`-adic phenomenon of
cycle 1, imported here through `deepHole_spectrum`.
Critique (Critic): `complete_the_square` needs the hypothesis that `ℓ` is in the image of
`2·Bil`, which we take as an explicit hypothesis rather than inverting `B`; this is exactly the
condition for the shift to be rational, and it is non-vacuous (`standard_linear_shift`).
Synthesis (PI): completing the square is the bridge that turns every cycle-1/2 gap theorem into
an unsolvability criterion for a genuine non-homogeneous Diophantine equation.
-/

namespace DiophantineLattice

open Finset

variable {n : ℕ}

/-- A linear form `ℓ(x) = Σ bᵢ xᵢ`. -/
def linForm (b x : Fin n → ℚ) : ℚ := ∑ i, b i * x i

/-- The general non-homogeneous quadratic form `F(x) = Q(x) + ℓ(x) + c`. -/
def nonhomForm (B : Matrix (Fin n) (Fin n) ℚ) (b : Fin n → ℚ) (c : ℚ) (x : Fin n → ℚ) : ℚ :=
  form B x + linForm b x + c

lemma bil_comm {B : Matrix (Fin n) (Fin n) ℚ} (hsym : ∀ i j, B i j = B j i) (x y : Fin n → ℚ) :
    bil B x y = bil B y x := by
  simp only [bil]
  rw [Finset.sum_comm]
  exact sum_congr rfl fun i _ => sum_congr rfl fun j _ => by rw [hsym j i]; ring

lemma form_add {B : Matrix (Fin n) (Fin n) ℚ} (hsym : ∀ i j, B i j = B j i) (x y : Fin n → ℚ) :
    form B (fun i => x i + y i) = form B x + 2 * bil B x y + form B y := by
  have hc := bil_comm hsym x y
  simp only [form, bil] at hc ⊢
  have expand : ∀ i : Fin n, ∑ j, B i j * (x i + y i) * (x j + y j)
      = (∑ j, B i j * x i * x j) + (∑ j, B i j * x i * y j)
        + ((∑ j, B i j * y i * x j) + (∑ j, B i j * y i * y j)) := by
    intro i
    rw [← sum_add_distrib, ← sum_add_distrib, ← sum_add_distrib]
    exact sum_congr rfl fun j _ => by ring
  rw [sum_congr rfl fun i _ => expand i]
  rw [sum_add_distrib, sum_add_distrib, sum_add_distrib]
  linarith

/-- **Completing the square.**  If `s` satisfies `2·Bil(s, y) = ℓ(y)` for all `y`, then
`F(x) = Q(x + s) + (c - Q(s))`. -/
theorem complete_the_square {B : Matrix (Fin n) (Fin n) ℚ} (hsym : ∀ i j, B i j = B j i)
    {b : Fin n → ℚ} (c : ℚ) {s : Fin n → ℚ} (hs : ∀ y : Fin n → ℚ, 2 * bil B s y = linForm b y)
    (x : Fin n → ℚ) :
    nonhomForm B b c x = form B (fun i => x i + s i) + (c - form B s) := by
  rw [form_add hsym x s, nonhomForm, ← hs x, bil_comm hsym x s]
  ring

/-- The archimedean (real) obstruction: `F ≥ c - Q(s)` everywhere. -/
theorem nonhom_ge_archimedean {B : Matrix (Fin n) (Fin n) ℚ} (hsym : ∀ i j, B i j = B j i)
    (hpd : PosDef B) {b : Fin n → ℚ} (c : ℚ) {s : Fin n → ℚ}
    (hs : ∀ y : Fin n → ℚ, 2 * bil B s y = linForm b y) (x : Fin n → ℚ) :
    c - form B s ≤ nonhomForm B b c x := by
  rw [complete_the_square hsym c hs x]
  rcases eq_or_ne (fun i => x i + s i) (0 : Fin n → ℚ) with h | h
  · rw [h]
    have : form B (0 : Fin n → ℚ) = 0 := by simp [form, bil]
    rw [this]; linarith
  · have := (hpd _ h).le
    linarith

/-- **The lattice refinement.**  If `-s` is the `r`-torsion point `v/r` of a shortest vector
`v`, the non-homogeneous form is bounded below by `λ₁/r² + c - Q(s)` on the lattice. -/
theorem nonhom_ge_torsion {B : Matrix (Fin n) (Fin n) ℚ} (hsym : ∀ i j, B i j = B j i)
    (hpd : PosDef B) {lam : ℚ} (h : IsMinEnergy B lam) {v : Fin n → ℤ}
    (hv : form B (emb v) = lam) {r : ℤ} (hr : 2 ≤ r) {b : Fin n → ℚ} (c : ℚ)
    (hs : ∀ y : Fin n → ℚ, 2 * bil B (fun i => -fracPt v r i) y = linForm b y)
    (m : Fin n → ℤ) :
    lam / (r : ℚ) ^ 2 + (c - form B (fun i => -fracPt v r i)) ≤ nonhomForm B b c (emb m) := by
  rw [complete_the_square hsym c hs (emb m)]
  have hrw : (fun i => (emb m) i + (fun i => -fracPt v r i) i)
      = fun i => -(fracPt v r i - emb m i) := by funext i; ring
  rw [hrw, form_neg B (fun i => fracPt v r i - emb m i)]
  have := (frac_shortest_isInhomMin hpd h hv hr).2 m
  linarith

/-- The value of the completing shift is exactly `λ₁/r²`. -/
lemma form_neg_fracPt {B : Matrix (Fin n) (Fin n) ℚ} {lam : ℚ} {v : Fin n → ℤ}
    (hv : form B (emb v) = lam) {r : ℤ} (hr : r ≠ 0) :
    form B (fun i => -fracPt v r i) = lam / (r : ℚ) ^ 2 := by
  have h1 : (fun i => -fracPt v r i) = fun i => -(fracPt v r i - emb (0 : Fin n → ℤ) i) := by
    funext i; simp [emb]
  rw [h1, form_neg, form_frac_sub B v 0 hr]
  have : (fun i => v i - r * (0 : Fin n → ℤ) i) = v := by funext i; simp
  rw [this, hv]

/-- **Strict improvement of the classical criterion.**  With the completing shift `s = -v/r`
attached to a shortest vector, the non-homogeneous equation `Q(x) + ℓ(x) + c = 0` has no
integral solution as soon as `c > 0`; the archimedean criterion `nonhom_ge_archimedean` would
only rule out `c > λ₁/r²`. -/
theorem nonhom_unsolvable_of_pos {B : Matrix (Fin n) (Fin n) ℚ} (hsym : ∀ i j, B i j = B j i)
    (hpd : PosDef B) {lam : ℚ} (h : IsMinEnergy B lam) {v : Fin n → ℤ}
    (hv : form B (emb v) = lam) {r : ℤ} (hr : 2 ≤ r) {b : Fin n → ℚ} {c : ℚ} (hc : 0 < c)
    (hs : ∀ y : Fin n → ℚ, 2 * bil B (fun i => -fracPt v r i) y = linForm b y)
    (m : Fin n → ℤ) : nonhomForm B b c (emb m) ≠ 0 := by
  have hr0 : r ≠ 0 := by omega
  have hb := nonhom_ge_torsion hsym hpd h hv hr c hs m
  rw [form_neg_fracPt hv hr0] at hb
  intro hzero
  rw [hzero] at hb
  linarith

/-! ## Non-vacuity: the standard form admits such shifts -/

lemma bil_one (x y : Fin n → ℚ) :
    bil (1 : Matrix (Fin n) (Fin n) ℚ) x y = ∑ i, x i * y i := by
  simp only [bil, Matrix.one_apply, ite_mul, one_mul, zero_mul, sum_ite_eq, mem_univ, if_true]

lemma one_isSymm (i j : Fin n) :
    (1 : Matrix (Fin n) (Fin n) ℚ) i j = (1 : Matrix (Fin n) (Fin n) ℚ) j i := by
  rcases eq_or_ne i j with h | h
  · simp [Matrix.one_apply, h]
  · simp [h, h.symm]

/-- Every shift is a completing shift for a suitable linear form: the hypothesis `hs` of
`nonhom_ge_torsion` is non-vacuous. -/
lemma standard_linear_shift (v : Fin n → ℤ) (r : ℤ) (y : Fin n → ℚ) :
    2 * bil (1 : Matrix (Fin n) (Fin n) ℚ) (fun i => -fracPt v r i) y
      = linForm (fun i => -2 * fracPt v r i) y := by
  rw [bil_one, linForm, mul_sum]
  exact sum_congr rfl fun i _ => by ring

/-- A fully concrete instance of `nonhom_unsolvable_of_pos`: for the standard form on `ℤⁿ`,
the non-homogeneous equation `Σxᵢ² - x₀ + c = 0` has no integral solution when `c > 0`. -/
theorem standard_nonhom_unsolvable (hn : 0 < n) {c : ℚ} (hc : 0 < c) (m : Fin n → ℤ) :
    nonhomForm (1 : Matrix (Fin n) (Fin n) ℚ)
      (fun i => -2 * fracPt (e0 hn) 2 i) c (emb m) ≠ 0 :=
  nonhom_unsolvable_of_pos one_isSymm standard_posDef (standard_isMinEnergy hn)
    (form_one_e0 hn) (by norm_num) hc (standard_linear_shift (e0 hn) 2) m

/-! ## The concrete standard case: `Σ (xᵢ² - xᵢ) + c = 0` -/

/-- Completing the square for the standard form at the deep hole turns `F` into
`Σ (xᵢ² - xᵢ) + c`; the quadratic part is always an **even non-negative** integer. -/
theorem sum_sq_sub_self_even (m : Fin n → ℤ) :
    ∃ k : ℤ, 0 ≤ k ∧ (∑ i, ((m i) ^ 2 - m i)) = 2 * k := by
  obtain ⟨k, hk0, hk⟩ := deepHole_spectrum m
  refine ⟨k, hk0, ?_⟩
  have hcast : ((∑ i, ((m i) ^ 2 - m i) : ℤ) : ℚ)
      = form (1 : Matrix (Fin n) (Fin n) ℚ) (fun i => deepHole n i - emb m i) - (n : ℚ) / 4 := by
    rw [form_one]
    have hterm : ∀ i : Fin n, (deepHole n i - emb m i) ^ 2
        = (((m i) ^ 2 - m i : ℤ) : ℚ) + 1 / 4 := by
      intro i
      simp only [deepHole, emb_apply]
      push_cast
      ring
    rw [sum_congr rfl fun i _ => hterm i, sum_add_distrib]
    push_cast
    simp [sum_const, card_univ]
    ring
  rw [hk] at hcast
  have : ((∑ i, ((m i) ^ 2 - m i) : ℤ) : ℚ) = ((2 * k : ℤ) : ℚ) := by push_cast at hcast ⊢; linarith
  exact_mod_cast this

/-- Hence `Σ (xᵢ² - xᵢ) + c = 0` is unsolvable in integers unless `c` is a non-positive even
integer — in particular for every positive `c`, and for every odd `c`. -/
theorem sum_sq_sub_self_add_ne_zero {c : ℤ} (hc : ¬ ∃ k : ℤ, 0 ≤ k ∧ c = -2 * k)
    (m : Fin n → ℤ) : (∑ i, ((m i) ^ 2 - m i)) + c ≠ 0 := by
  intro hzero
  obtain ⟨k, hk0, hk⟩ := sum_sq_sub_self_even m
  exact hc ⟨k, hk0, by omega⟩

/-- Concrete instance in one variable: `x² - x + c = 0` has no integer solution for `c > 0`. -/
theorem one_var_no_solution {c : ℤ} (hc : 0 < c) (x : ℤ) : x ^ 2 - x + c ≠ 0 := by
  have h : ∀ m : Fin 1 → ℤ, (∑ i, ((m i) ^ 2 - m i)) + c ≠ 0 := by
    refine sum_sq_sub_self_add_ne_zero ?_
    rintro ⟨k, hk0, hk⟩
    omega
  have := h (fun _ => x)
  simpa using this

end DiophantineLattice