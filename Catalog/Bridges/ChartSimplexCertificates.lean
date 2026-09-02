/-
# Simplex-lattice certificates and the exact node count `C(n+d, n)`

`Bridges.ChartSimplexUnisolvence` proves that the simplex lattice
`S(n,d) = {a ∈ ℕⁿ : ∑ aᵢ ≤ d}` is a minimum-cardinality uniqueness set for polynomials of
total degree `≤ d`.  This file makes the statement *effective*:

* `ChartCalculus.simplexTuples` is a computable `Finset` presentation of `S(n,d)`;
* `ChartCalculus.card_simplexTuples` computes its cardinality exactly: `C(n+d, n)`,
  which — combined with `card_simplexNodes` — also gives the count
  `#(monomialsLE n d) = C(n+d, n)` of monomials of total degree `≤ d`;
* `ChartCalculus.NExpr.SimplexCert` is a decidable identity certificate, proved sound
  *and* complete in `simplexCert_iff_toZ_eq`, and transported to every commutative ring by
  `universal_of_simplexCert`;
* two classical identities are re-proved from simplex certificates using strictly fewer
  evaluation points than the box grid needs (`10` instead of `16`, `20` instead of `64`).

Main results:
* `ChartCalculus.card_simplexTuples` — `#S(n,d) = C(n+d, n)`.
* `ChartCalculus.card_monomialsLE_choose` — the dimension count `C(n+d, n)`.
* `ChartCalculus.NExpr.simplexCert_iff_toZ_eq` — soundness and completeness.
* `ChartCalculus.NExpr.decEqToZ_simplex` — decidability of identity by the optimal check.
* `ChartCalculus.NExpr.cube_identity_simplex`, `ChartCalculus.NExpr.sym_identity_simplex`.
-/
import Bridges.ChartSimplexUnisolvence

open MvPolynomial

namespace ChartCalculus

/-! ## A computable presentation of the simplex lattice -/

/-- The simplex lattice `{a ∈ ℕⁿ : ∑ aᵢ ≤ d}` as a computable `Finset`. -/
def simplexTuples (n d : ℕ) : Finset (Fin n → ℕ) :=
  (Fintype.piFinset (fun _ : Fin n => Finset.range (d + 1))).filter (fun a => ∑ i, a i ≤ d)

@[simp] theorem mem_simplexTuples {n d : ℕ} {a : Fin n → ℕ} :
    a ∈ simplexTuples n d ↔ ∑ i, a i ≤ d := by
  rw [simplexTuples, Finset.mem_filter]
  refine ⟨fun h => h.2, fun h => ⟨Fintype.mem_piFinset.mpr (fun i => Finset.mem_range.mpr ?_), h⟩⟩
  have : a i ≤ ∑ j, a j :=
    Finset.single_le_sum (f := fun j => a j) (fun j _ => Nat.zero_le _) (Finset.mem_univ i)
  omega

theorem simplexTuples_eq_simplexNodes (n d : ℕ) : simplexTuples n d = simplexNodes n d := by
  ext a
  rw [mem_simplexTuples, mem_simplexNodes]

/-! ## The exact count -/

/-- Hockey-stick identity: `∑_{j ≤ d} C(n+j, n) = C(n+d+1, n+1)`. -/
theorem sum_choose_hockey (n d : ℕ) :
    ∑ j ∈ Finset.range (d + 1), (n + j).choose n = (n + d + 1).choose (n + 1) := by
  induction d with
  | zero => simp
  | succ d ih =>
      rw [Finset.sum_range_succ, ih, show n + (d + 1) = n + d + 1 from by ring,
        Nat.choose_succ_succ (n + d + 1) n]
      simp only [Nat.succ_eq_add_one]
      omega

/-- **The simplex lattice has exactly `C(n+d, n)` points** — precisely the dimension of the
space of polynomials of total degree `≤ d` in `n` variables. -/
theorem card_simplexTuples (n d : ℕ) : (simplexTuples n d).card = (n + d).choose n := by
  induction n generalizing d with
  | zero => simp [simplexTuples]
  | succ n ih =>
      have hfib : (simplexTuples (n + 1) d).card
          = ∑ k ∈ Finset.range (d + 1),
              ((simplexTuples (n + 1) d).filter (fun a => a 0 = k)).card := by
        refine Finset.card_eq_sum_card_fiberwise (fun a ha => ?_)
        have h := mem_simplexTuples.mp ha
        have h0 : a 0 ≤ ∑ j, a j :=
          Finset.single_le_sum (f := fun j => a j) (fun j _ => Nat.zero_le _) (Finset.mem_univ 0)
        exact Finset.mem_range.mpr (by omega)
      have hcard : ∀ k ∈ Finset.range (d + 1),
          ((simplexTuples (n + 1) d).filter (fun a => a 0 = k)).card
            = (simplexTuples n (d - k)).card := by
        intro k hk
        have hkd : k ≤ d := Nat.lt_succ_iff.mp (Finset.mem_range.mp hk)
        refine Finset.card_bij (fun a _ => Fin.tail a) ?_ ?_ ?_
        · intro a ha
          simp only [Finset.mem_filter] at ha
          have h1 := mem_simplexTuples.mp ha.1
          rw [Fin.sum_univ_succ, ha.2] at h1
          refine mem_simplexTuples.mpr ?_
          simpa [Fin.tail] using by omega
        · intro a ha a' ha' h
          simp only [Finset.mem_filter] at ha ha'
          funext i
          refine Fin.cases ?_ ?_ i
          · rw [ha.2, ha'.2]
          · intro j; exact congrFun h j
        · intro b hb
          refine ⟨Fin.cons k b, ?_, ?_⟩
          · simp only [Finset.mem_filter]
            refine ⟨mem_simplexTuples.mpr ?_, by simp⟩
            rw [Fin.sum_univ_succ]
            have := mem_simplexTuples.mp hb
            simp only [Fin.cons_zero, Fin.cons_succ]
            omega
          · funext j; simp [Fin.tail]
      rw [hfib, Finset.sum_congr rfl hcard]
      simp only [ih]
      have h := Finset.sum_range_reflect (fun j => (n + j).choose n) (d + 1)
      simp only [Nat.add_sub_cancel] at h
      rw [h, sum_choose_hockey n d, show n + 1 + d = n + d + 1 from by ring]

/-- The number of monomials of total degree `≤ d` in `n` variables is `C(n+d, n)`. -/
theorem card_monomialsLE_choose (n d : ℕ) : (monomialsLE n d).card = (n + d).choose n := by
  rw [← card_simplexNodes, ← simplexTuples_eq_simplexNodes, card_simplexTuples]

/-- Over a characteristic-zero field, the optimal uniqueness set for total degree `≤ d`
has exactly `C(n+d, n)` points, and the simplex lattice realises this bound. -/
theorem card_simplexPoints_choose {K : Type*} [Field K] [CharZero K] (n d : ℕ) :
    (simplexPoints K n d).card = (n + d).choose n := by
  rw [card_simplexPoints, card_monomialsLE_choose]

/-! ## The decidable simplex certificate -/

namespace NExpr

variable {n : ℕ}

/-- The simplex certificate: agreement at the `C(n+d, n)` lattice points of `S(n,d)`. -/
def SimplexCert (d : ℕ) (e₁ e₂ : NExpr n) : Prop :=
  ∀ a ∈ simplexTuples n d, eval (fun i => ((a i : ℕ) : ℤ)) e₁ = eval (fun i => ((a i : ℕ) : ℤ)) e₂

instance (d : ℕ) (e₁ e₂ : NExpr n) : Decidable (SimplexCert d e₁ e₂) :=
  inferInstanceAs (Decidable (∀ a ∈ _, _))

/-- **Soundness and completeness of the simplex certificate.**  For expressions of
syntactic degree at most `d`, agreement on the `C(n+d, n)` simplex points is *equivalent*
to denoting the same polynomial. -/
theorem simplexCert_iff_toZ_eq {d : ℕ} (e₁ e₂ : NExpr n) (h₁ : e₁.deg ≤ d) (h₂ : e₂.deg ≤ d) :
    SimplexCert d e₁ e₂ ↔ e₁.toZ = e₂.toZ := by
  constructor
  · intro hc
    refine eq_of_eval_eq_on_simplex (K := ℤ) e₁.toZ e₂.toZ ((totalDegree_toZ_le e₁).trans h₁)
      ((totalDegree_toZ_le e₂).trans h₂) (fun a ha => ?_)
    rw [← eval_int, ← eval_int]
    exact hc a (mem_simplexTuples.mpr ha)
  · intro h a _
    exact eval_eq_of_toZ_eq e₁ e₂ h _

/-- Equality of denotations is decidable by the *optimal* check: `C(n+d, n)` evaluations
at the simplex lattice, rather than `(d+1)^n` at the box grid. -/
def decEqToZ_simplex (e₁ e₂ : NExpr n) : Decidable (e₁.toZ = e₂.toZ) :=
  decidable_of_iff (SimplexCert (max e₁.deg e₂.deg) e₁ e₂)
    (simplexCert_iff_toZ_eq e₁ e₂ (le_max_left _ _) (le_max_right _ _))

/-- A verified simplex check certifies the identity in every commutative ring. -/
theorem universal_of_simplexCert {d : ℕ} {e₁ e₂ : NExpr n} (h₁ : e₁.deg ≤ d) (h₂ : e₂.deg ≤ d)
    (hc : SimplexCert d e₁ e₂) {R : Type*} [CommRing R] (x : Fin n → R) :
    e₁.eval x = e₂.eval x :=
  eval_eq_of_toZ_eq e₁ e₂ ((simplexCert_iff_toZ_eq e₁ e₂ h₁ h₂).mp hc) x

/-! ## Worked certificates with strictly fewer points -/

/-- The degree-`3`, two-variable simplex lattice has `10` points, against `16` for the
box grid `{0,1,2,3}²`. -/
theorem card_simplexTuples_two_three : (simplexTuples 2 3).card = 10 := by
  rw [card_simplexTuples]
  decide

/-- The degree-`3`, three-variable simplex lattice has `20` points, against `64` for the
box grid `{0,1,2,3}³`. -/
theorem card_simplexTuples_three_three : (simplexTuples 3 3).card = 20 := by
  rw [card_simplexTuples]
  decide

set_option maxRecDepth 40000 in
theorem cube_simplexCert : SimplexCert 3 cubeLHS cubeRHS := by decide

/-- The binomial cube identity in an arbitrary commutative ring, from a check on the `10`
simplex points (the box-grid proof `cube_identity` uses `16`). -/
theorem cube_identity_simplex {R : Type*} [CommRing R] (a b : R) :
    (a + b) ^ 3 = a ^ 3 + 3 * (a ^ 2 * b) + 3 * (a * b ^ 2) + b ^ 3 := by
  have h := universal_of_simplexCert (d := 3) (e₁ := cubeLHS) (e₂ := cubeRHS)
    (by decide) (by decide) cube_simplexCert (R := R) ![a, b]
  simp only [cubeLHS, cubeRHS, eval, Matrix.cons_val_zero, Matrix.cons_val_one] at h
  rw [show ((3 : ℤ) : R) = 3 by push_cast; ring] at h
  linear_combination h

set_option maxRecDepth 100000 in
theorem sym_simplexCert : SimplexCert 3 symLHS symRHS := by decide

/-- The factorisation `a³ + b³ + c³ - 3abc = (a+b+c)(a²+b²+c² - ab - bc - ca)` in an
arbitrary commutative ring, from a check on the `20` simplex points (the box-grid proof
uses `64`). -/
theorem sym_identity_simplex {R : Type*} [CommRing R] (a b c : R) :
    a ^ 3 + b ^ 3 + c ^ 3 - 3 * (a * b * c)
      = (a + b + c) * (a ^ 2 + b ^ 2 + c ^ 2 - a * b - b * c - c * a) := by
  have h := universal_of_simplexCert (d := 3) (e₁ := symLHS) (e₂ := symRHS)
    (by decide) (by decide) sym_simplexCert (R := R) ![a, b, c]
  simp only [symLHS, symRHS, eval, Matrix.cons_val_zero, Matrix.cons_val_one,
    Matrix.cons_val_two] at h
  rw [show ((3 : ℤ) : R) = 3 by push_cast; ring] at h
  linear_combination h

end NExpr

end ChartCalculus