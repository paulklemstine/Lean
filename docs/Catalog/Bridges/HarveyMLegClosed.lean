import Mathlib

/-!
# Round 35: the baby-step `m`-leg of Harvey's `N^{1/5}` algorithm is a closed variable,
# and "add a floor" reduces to "add weight"

Harvey's deterministic `N^{1/5}` factoring algorithm (Math. Comp. 90 (2021); arXiv:2010.05450)
is modelled in the catalog (`Crypto.FactoringBarrier.HarveyFloor`,
`Crypto.FactoringBarrier.HarveyBalance`, `Logic.HarveyFaithfulSlackness`) by the cost
`max{ A, B, C } = max{ N^{1/2}/(r^{1/2} m), r, m }`, i.e. in exponent form
(`r = N^a`, `m = N^b`) `max{ 1/2 - a/2 - b, a, b }` (the catalog's `costExp` / `relaxExp`).

This file is self-contained (it imports only Mathlib); the exponent function below is
literally the catalog's `HarveyBalance.costExp`.  It proves the three "pins" on the `m`-leg
and turns the proposed "add a floor" lever into a theorem.

## Pin 1 — `A · C` is one degree of freedom (`ac_product_invariant`, `ac_collapse_*`)
`A · C = N^{1/2}/r^{1/2}` does not depend on `m`; `max(A, C) ≥ √(A·C)` with equality at the
balanced split.  Minimising over `m` collapses the interior and the `m`-leg into the single
term `(N/r)^{1/4}` — **exactly the `M`-leg of Harvey's Algorithm 4.3 Step 2**
(`ac_collapse_exp`, `ac_collapse_real`).  This explains the catalog's observation that the
value `1/5` has two certificates `{M-leg, r}` and `{interior, r, m}`: the second one *is*
the first one after optimising out `m`.

## Pin 2 — output counting (`slpRun_length`, `slp_distinct_le`)
A straight-line monoid program with `t` multiplications outputs at most `t + 1` distinct
elements, so producing `m` distinct group elements needs at least `m - 1` multiplications.
The baby-step chain `α, α², …, α^m` achieves this with exactly `m - 1` multiplications
(`babyChain_run`, `babyChain_optimal`).

## Pin 3 — injectivity is a correctness hypothesis (`babyChain_nodup`, `babyChain_collision`)
If `m ≤ ord(α)` the baby steps are pairwise distinct (Harvey Step 3: "each `v_{a,b,j}` is
equal to at most one `α_i`"), and the bound is sharp: if `0 < ord(α) < m` there is a
collision.

## LP sensitivity / shadow prices (`dual_certificate`, `harvey_sensitivity`)
A general convex-combination (LP dual) certificate, and the exact sensitivity of the
optimum: cheapening the three legs by exponents `ε₁ (r), ε₂ (m), ε₃ (interior)` lowers the
optimum by exactly `(ε₁ + 2ε₂ + 2ε₃)/5`.  Shadow prices `(1/5, 2/5, 2/5)`; the `m`-leg and
interior jointly carry `4/5` — the LP shadow of Pin 1.

## Faithful model (`faithful_floor_lower`, `faithful_floor_needs_both`, `faithful_floor_sixth_*`)
If the new floor also enters the `M`-leg with weight `θ`, the cost is at least
`max(1/(5+4θ), 1/(5+2w))`; beating `1/5` needs `θ > 0` and `w > 0`, and `1/6` needs
`θ ≥ 1/4`, `w ≥ 1/2` (attained).

## "Add a floor" (`floor_lower`, `floor_attained`, `pure_floor_useless`,
## `floor_beneficial_iff`, `harvey_floor_break_even`)
Adding a new term to the `max` can never lower the optimum (`max_add_term_monotone`), and a new
floor `c` that does not enter the interior (weight `w = 0`) is useless.  A new floor of
interior weight `w > 0` bought at a numerator overhead `δ` gives optimum exactly
`(γ + δ)/(2 + α + w)`; it beats the old optimum iff `δ (2 + α) < γ w`, i.e. for Harvey iff
`δ < w/5`.  So **"add a floor" is the weight lever in disguise**: its only effect is to add
`w` to the AM–GM denominator, and its break-even overhead is `w/5`.
-/

namespace Bridges.HarveyMLegClosed

open Finset

/-! ## Pin 2: output counting for straight-line monoid programs -/

section SLP

variable {G : Type*} [Monoid G]

/-- One step of a straight-line program: append the product of two earlier entries
(out-of-range indices read as `1`). -/
def slpStep (acc : List G) (ij : ℕ × ℕ) : List G :=
  acc ++ [acc.getD ij.1 1 * acc.getD ij.2 1]

/-- Run a straight-line program from the single input `g₀`; every instruction is one
multiplication. -/
def slpRun (g₀ : G) (prog : List (ℕ × ℕ)) : List G :=
  prog.foldl slpStep [g₀]

theorem foldl_slpStep_length (prog : List (ℕ × ℕ)) :
    ∀ acc : List G, (prog.foldl slpStep acc).length = acc.length + prog.length := by
  induction prog with
  | nil => intro acc; simp
  | cons ij rest ih =>
    intro acc
    simp only [List.foldl_cons, List.length_cons]
    rw [ih]
    simp [slpStep]
    omega

/-- A program with `t` multiplications produces a list of exactly `t + 1` values. -/
theorem slpRun_length (g₀ : G) (prog : List (ℕ × ℕ)) :
    (slpRun g₀ prog).length = prog.length + 1 := by
  rw [slpRun, foldl_slpStep_length]; simp; omega

/-- **Output counting.** Any set of distinct elements produced by a straight-line program
with `t` multiplications has at most `t + 1` elements. -/
theorem slp_distinct_le [DecidableEq G] (g₀ : G) (prog : List (ℕ × ℕ)) (S : Finset G)
    (hS : ∀ x ∈ S, x ∈ slpRun g₀ prog) : S.card ≤ prog.length + 1 := by
  have hsub : S ⊆ (slpRun g₀ prog).toFinset := fun x hx => List.mem_toFinset.mpr (hS x hx)
  calc S.card ≤ (slpRun g₀ prog).toFinset.card := Finset.card_le_card hsub
    _ ≤ (slpRun g₀ prog).length := List.toFinset_card_le _
    _ = prog.length + 1 := slpRun_length g₀ prog

/-- The baby-step program: step `j` multiplies entry `j` (which is `α^{j+1}`) by entry `0`
(which is `α`). -/
def babyProg (k : ℕ) : List (ℕ × ℕ) := (List.range k).map (fun j => (j, 0))

theorem foldl_baby (α : G) (k : ℕ) :
    ∀ n : ℕ, ((List.range' n k).map (fun j => (j, 0))).foldl slpStep
        ((List.range (n + 1)).map (fun i => α ^ (i + 1)))
      = (List.range (n + 1 + k)).map (fun i => α ^ (i + 1)) := by
  induction k with
  | zero => intro n; simp
  | succ k ih =>
    intro n
    rw [List.range'_succ, List.map_cons, List.foldl_cons]
    have hstep : slpStep ((List.range (n + 1)).map (fun i => α ^ (i + 1))) (n, 0)
        = (List.range (n + 1 + 1)).map (fun i => α ^ (i + 1)) := by
      rw [slpStep, show List.range (n + 1 + 1) = List.range (n + 1) ++ [n + 1] from List.range_succ,
        List.map_append]
      congr 1
      simp [List.getD_eq_getElem?_getD, pow_succ]
    rw [hstep, ih (n + 1)]
    congr 2
    omega

/-- **The baby-step chain computes `α, α², …, α^{k+1}` with `k` multiplications.** -/
theorem babyChain_run (α : G) (k : ℕ) :
    slpRun α (babyProg k) = (List.range (k + 1)).map (fun i => α ^ (i + 1)) := by
  have h := foldl_baby α k 0
  simp only [zero_add, List.range_one, List.map_singleton, pow_one] at h
  rw [slpRun, babyProg, List.range_eq_range', h, Nat.add_comm]

end SLP

/-! ## Pin 3: injectivity of the baby steps, and its sharpness -/

section Injectivity

variable {G : Type*} [Group G]

/-- **Harvey Step 3 injectivity.** If `m ≤ ord(α)`, the `m` baby steps `α, …, α^m` are
pairwise distinct. -/
theorem babyChain_nodup (α : G) (m : ℕ) (hm : m ≤ orderOf α) :
    ((List.range m).map (fun i => α ^ (i + 1))).Nodup := by
  rw [List.nodup_map_iff_inj_on (List.nodup_range)]
  intro i hi j hj hij
  simp only [List.mem_range] at hi hj
  have h' : α ^ i = α ^ j := by
    rw [pow_succ, pow_succ] at hij
    exact mul_right_cancel hij
  exact pow_injOn_Iio_orderOf (by simpa using lt_of_lt_of_le hi hm)
    (by simpa using lt_of_lt_of_le hj hm) h'

/-- **The injectivity hypothesis is sharp.** If `0 < ord(α) < m`, two baby steps coincide
(`α¹ = α^{ord(α)+1}`), so the "at most one `α_i`" property, and with it correctness of the
matching step, fails. -/
theorem babyChain_collision (α : G) (m : ℕ) (h0 : 0 < orderOf α) (hlt : orderOf α < m) :
    ¬ ((List.range m).map (fun i => α ^ (i + 1))).Nodup := by
  intro hnd
  rw [List.nodup_map_iff_inj_on (List.nodup_range)] at hnd
  have h := hnd 0 (by simp; omega) (orderOf α) (by simpa using hlt)
    (by simp [pow_succ, pow_orderOf_eq_one])
  omega

/-- **The `m`-leg is already information-theoretically optimal.** If `m ≤ ord(α)`:
(i) any straight-line program whose outputs include the `m` baby steps uses at least
`m - 1` multiplications, and (ii) the baby-step chain uses exactly `m - 1`. -/
theorem babyChain_optimal [DecidableEq G] (α : G) (m : ℕ) (hm1 : 1 ≤ m) (hm : m ≤ orderOf α) :
    (∀ (g₀ : G) (prog : List (ℕ × ℕ)),
        (∀ i < m, α ^ (i + 1) ∈ slpRun g₀ prog) → m - 1 ≤ prog.length) ∧
      slpRun α (babyProg (m - 1)) = (List.range m).map (fun i => α ^ (i + 1)) := by
  refine ⟨fun g₀ prog hprog => ?_, ?_⟩
  · set S := ((List.range m).map (fun i => α ^ (i + 1))).toFinset
    have hcard : S.card = m := by
      rw [List.toFinset_card_of_nodup (babyChain_nodup α m hm)]; simp
    have hS : ∀ x ∈ S, x ∈ slpRun g₀ prog := by
      intro x hx
      simp only [S, List.mem_toFinset, List.mem_map, List.mem_range] at hx
      obtain ⟨i, hi, rfl⟩ := hx
      exact hprog i hi
    have := slp_distinct_le g₀ prog S hS
    omega
  · rw [babyChain_run]
    congr 2
    omega

end Injectivity

/-! ## The exponent model (the catalog's `HarveyBalance.costExp`) -/

/-- Harvey's three-leg cost exponent: `r = N^a` (pair floor), `m = N^b` (baby steps),
interior `N^{1/2 - a/2 - b}`.  Identical to `HarveyBalance.costExp`. -/
noncomputable def costExp (a b : ℝ) : ℝ := max a (max b (1 / 2 - a / 2 - b))

/-! ## LP duality and shadow prices -/

/-- **The LP dual certificate.** If nonnegative multipliers `λᵢ` summing to `1` combine the
legs `ℓᵢ` into the constant `c`, then any common upper bound `T` of the legs is `≥ c`.
Every lower bound in this file (and in `HarveyFloor`) is an instance. -/
theorem dual_certificate {ι : Type*} (s : Finset ι) (ℓ lam : ι → ℝ) (c T : ℝ)
    (hlam : ∀ i ∈ s, 0 ≤ lam i) (hsum : ∑ i ∈ s, lam i = 1)
    (hcomb : ∑ i ∈ s, lam i * ℓ i = c) (hT : ∀ i ∈ s, ℓ i ≤ T) : c ≤ T := by
  rw [← hcomb]
  calc ∑ i ∈ s, lam i * ℓ i ≤ ∑ i ∈ s, lam i * T :=
        Finset.sum_le_sum fun i hi => mul_le_mul_of_nonneg_left (hT i hi) (hlam i hi)
    _ = T := by rw [← Finset.sum_mul, hsum, one_mul]

/-- Harvey's certificate is `λ = (1/5, 2/5, 2/5)` on `(r, m, interior)`, an instance of
`dual_certificate` over `Fin 3`. -/
theorem harvey_dual_certificate (a b : ℝ) : 1 / 5 ≤ costExp a b := by
  have h := dual_certificate (Finset.univ : Finset (Fin 3)) ![a, b, 1 / 2 - a / 2 - b]
    ![1 / 5, 2 / 5, 2 / 5] (1 / 5) (costExp a b)
    (by intro i _; fin_cases i <;> norm_num) (by simp [Fin.sum_univ_three]; norm_num)
    (by simp [Fin.sum_univ_three]; ring)
    (by
      intro i _
      fin_cases i
      · exact le_max_left _ _
      · exact le_trans (le_max_left _ _) (le_max_right _ _)
      · exact le_trans (le_max_right _ _) (le_max_right _ _))
  exact h

/-- The cheapened cost: the legs `r, m, interior` lowered by exponents `e₁, e₂, e₃`. -/
noncomputable def cheapExp (e₁ e₂ e₃ a b : ℝ) : ℝ := max (a - e₁) (max (b - e₂) (1 / 2 - a / 2 - b - e₃))

/-- **Exact LP sensitivity (lower half).** Cheapening the legs by `(e₁, e₂, e₃)` lowers the
optimum by **at most** `(e₁ + 2e₂ + 2e₃)/5`, for every choice of `a, b`. -/
theorem harvey_sensitivity (e₁ e₂ e₃ a b : ℝ) :
    1 / 5 - (e₁ + 2 * e₂ + 2 * e₃) / 5 ≤ cheapExp e₁ e₂ e₃ a b := by
  unfold cheapExp
  have h1 := le_max_left (a - e₁) (max (b - e₂) (1 / 2 - a / 2 - b - e₃))
  have h2 := le_trans (le_max_left (b - e₂) (1 / 2 - a / 2 - b - e₃))
    (le_max_right (a - e₁) _)
  have h3 := le_trans (le_max_right (b - e₂) (1 / 2 - a / 2 - b - e₃))
    (le_max_right (a - e₁) _)
  linarith

/-- **Exact LP sensitivity (attainment).** The bound of `harvey_sensitivity` is achieved,
so the shadow prices of `(r, m, interior)` are exactly `(1/5, 2/5, 2/5)`. -/
theorem harvey_sensitivity_attained (e₁ e₂ e₃ : ℝ) :
    ∃ a b : ℝ, cheapExp e₁ e₂ e₃ a b = 1 / 5 - (e₁ + 2 * e₂ + 2 * e₃) / 5 := by
  set t := 1 / 5 - (e₁ + 2 * e₂ + 2 * e₃) / 5
  refine ⟨t + e₁, t + e₂, ?_⟩
  unfold cheapExp
  have h3 : 1 / 2 - (t + e₁) / 2 - (t + e₂) - e₃ = t := by simp only [t]; ring
  rw [h3]; simp

/-- **No power-of-`N` gain from the `m`-leg alone, given Pin 2.** If the `m`-leg cannot be
cheapened (`e₂ ≤ 0`, output counting) and the interior is not touched (`e₃ = 0`, injectivity
pins the benefit at weight 1), the only remaining gain is through the pair floor, at price
`1/5`. -/
theorem mleg_closed (e₁ e₂ a b : ℝ) (he₂ : e₂ ≤ 0) :
    1 / 5 - e₁ / 5 ≤ cheapExp e₁ e₂ 0 a b := by
  have := harvey_sensitivity e₁ e₂ 0 a b
  linarith

/-! ## Pin 1: `A · C` is a single degree of freedom -/

/-- **Exponent form of Pin 1.** For every pair-floor exponent `a`, the `m`-leg and the
interior together cost at least `(1 - a)/4` — exactly the exponent of Harvey's `M`-leg
`(N/r)^{1/4}` — whatever `b` is. -/
theorem ac_collapse_exp (a b : ℝ) : (1 - a) / 4 ≤ max b (1 / 2 - a / 2 - b) := by
  have h1 := le_max_left b (1 / 2 - a / 2 - b)
  have h2 := le_max_right b (1 / 2 - a / 2 - b)
  linarith

/-- ... and it is attained at the balanced split `b = (1 - a)/4`. -/
theorem ac_collapse_exp_attained (a : ℝ) :
    max ((1 - a) / 4) (1 / 2 - a / 2 - (1 - a) / 4) = (1 - a) / 4 := by
  have : 1 / 2 - a / 2 - (1 - a) / 4 = (1 - a) / 4 := by ring
  rw [this, max_self]

/-- **Optimising out `m` turns Harvey's three-leg cost into the two-leg `{M-leg, r}` cost.**
For every `a`, `min_b costExp a b = max(a, (1 - a)/4)`. (Lower bound for every `b`,
attained at `b = (1-a)/4`.) -/
theorem costExp_min_over_b (a : ℝ) :
    (∀ b, max a ((1 - a) / 4) ≤ costExp a b) ∧
      costExp a ((1 - a) / 4) = max a ((1 - a) / 4) := by
  refine ⟨fun b => max_le_max (le_refl a) (ac_collapse_exp a b), ?_⟩
  unfold costExp
  rw [ac_collapse_exp_attained]

/-- Elementary AM–GM for the max: `x y ≤ max(x,y)²` for `x, y ≥ 0`. -/
theorem mul_le_max_sq (x y : ℝ) (hx : 0 ≤ x) (hy : 0 ≤ y) : x * y ≤ max x y ^ 2 := by
  rcases le_total x y with h | h
  · rw [max_eq_right h]; nlinarith
  · rw [max_eq_left h]; nlinarith

/-- **Pin 1, real form: the product `A · C` is invariant under re-splitting `m`.** -/
theorem ac_product_invariant (N r m : ℝ) (hm : 0 < m) :
    N ^ ((1 : ℝ) / 2) / (r ^ ((1 : ℝ) / 2) * m) * m = N ^ ((1 : ℝ) / 2) / r ^ ((1 : ℝ) / 2) := by
  field_simp

/-- **Pin 1, real form: `max(A, C) ≥ (N/r)^{1/4}` for every `m > 0`,** i.e. the interior
and the `m`-leg together can never cost less than Harvey's `M`-leg. -/
theorem ac_collapse_real (N r m : ℝ) (hN : 0 < N) (hr : 0 < r) (hm : 0 < m) :
    (N / r) ^ ((1 : ℝ) / 4) ≤ max (N ^ ((1 : ℝ) / 2) / (r ^ ((1 : ℝ) / 2) * m)) m := by
  set A := N ^ ((1 : ℝ) / 2) / (r ^ ((1 : ℝ) / 2) * m)
  have hA : 0 < A := by positivity
  have hprod : A * m = (N / r) ^ ((1 : ℝ) / 2) := by
    rw [ac_product_invariant N r m hm, Real.div_rpow hN.le hr.le]
  have hsq : ((N / r) ^ ((1 : ℝ) / 4)) ^ 2 = (N / r) ^ ((1 : ℝ) / 2) := by
    rw [← Real.rpow_natCast, ← Real.rpow_mul (by positivity)]; norm_num
  have hkey : ((N / r) ^ ((1 : ℝ) / 4)) ^ 2 ≤ (max A m) ^ 2 := by
    rw [hsq, ← hprod]; exact mul_le_max_sq A m hA.le hm.le
  have hM : 0 ≤ max A m := le_trans hA.le (le_max_left _ _)
  exact (pow_le_pow_iff_left₀ (by positivity) hM (by norm_num)).mp hkey

/-! ## "Add a floor": the new lever reduces to the weight lever -/

/-- **Adding a term to a `max` can only raise it.** Hence adding a floor *without* changing
any existing term can never lower the optimum of any cost of max-shape. -/
theorem max_add_term_monotone {P : Type*} (f F : P → ℝ) (L : ℝ) (hL : ∀ p, L ≤ f p) :
    ∀ p, L ≤ max (f p) (F p) := fun p => le_trans (hL p) (le_max_left _ _)

/-- The four-leg exponent after adding a floor `s = N^c` that enters the interior with
weight `w`, at a numerator overhead `δ`: legs `a, b, c` and interior
`γ + δ - α a - b - w c` (Harvey: `γ = α = 1/2`, `δ = 0`). -/
noncomputable def floorExp (γ δ α w a b c : ℝ) : ℝ := max a (max b (max c (γ + δ - α * a - b - w * c)))

/-- **Lower bound for the added floor (the four-leg weighted AM–GM).** For `α, w ≥ 0`,
`floorExp ≥ (γ + δ)/(2 + α + w)`. -/
theorem floor_lower (γ δ α w a b c : ℝ) (hα : 0 ≤ α) (hw : 0 ≤ w) :
    (γ + δ) / (2 + α + w) ≤ floorExp γ δ α w a b c := by
  set T := floorExp γ δ α w a b c
  have ha : a ≤ T := le_max_left _ _
  have hb : b ≤ T := le_trans (le_max_left _ _) (le_max_right _ _)
  have hc : c ≤ T := le_trans (le_trans (le_max_left _ _) (le_max_right _ _)) (le_max_right _ _)
  have hI : γ + δ - α * a - b - w * c ≤ T :=
    le_trans (le_trans (le_max_right _ _) (le_max_right _ _)) (le_max_right _ _)
  have h1 : α * a ≤ α * T := mul_le_mul_of_nonneg_left ha hα
  have h2 : w * c ≤ w * T := mul_le_mul_of_nonneg_left hc hw
  rw [div_le_iff₀ (by linarith)]
  nlinarith

/-- **Attainment:** all four legs equal `(γ + δ)/(2 + α + w)` at the balanced point. -/
theorem floor_attained (γ δ α w : ℝ) (hα : 0 ≤ α) (hw : 0 ≤ w) :
    let t := (γ + δ) / (2 + α + w)
    floorExp γ δ α w t t t = t := by
  intro t
  have hpos : (2 + α + w) ≠ 0 := by linarith
  have hI : γ + δ - α * t - t - w * t = t := by
    simp only [t]; field_simp; ring
  unfold floorExp
  rw [hI]; simp

/-- **A floor that does not enter the interior (`w = 0`) and costs no less (`δ ≥ 0`) is
useless:** the optimum is at least the old optimum `γ/(2 + α)`. This is the formal content of
"add a floor without changing the functional form of the interior". -/
theorem pure_floor_useless (γ δ α a b c : ℝ) (hα : 0 ≤ α) (hδ : 0 ≤ δ) :
    γ / (2 + α) ≤ floorExp γ δ α 0 a b c := by
  have h := floor_lower γ δ α 0 a b c hα le_rfl
  have hle : γ / (2 + α) ≤ (γ + δ) / (2 + α + 0) := by
    rw [add_zero]; exact div_le_div_of_nonneg_right (by linarith) (by linarith)
  linarith

/-- **The break-even law for adding a floor.** For `α, w ≥ 0` (any `γ`, `δ`), the new optimum
`(γ + δ)/(2 + α + w)` beats the old optimum `γ/(2 + α)` **iff** `δ (2 + α) < γ w`. -/
theorem floor_beneficial_iff (γ δ α w : ℝ) (hα : 0 ≤ α) (hw : 0 ≤ w) :
    (γ + δ) / (2 + α + w) < γ / (2 + α) ↔ δ * (2 + α) < γ * w := by
  rw [div_lt_div_iff₀ (by linarith) (by linarith)]
  constructor <;> intro h <;> nlinarith

/-- **Harvey's instance:** a new floor of interior weight `w` bought at overhead `δ` beats
`N^{1/5}` iff `δ < w/5`; with no overhead, weight `1/2` gives exactly `1/6`. -/
theorem harvey_floor_break_even (δ w : ℝ) (hw : 0 ≤ w) :
    (1 / 2 + δ) / (2 + 1 / 2 + w) < 1 / 5 ↔ δ < w / 5 := by
  have h := floor_beneficial_iff (1 / 2) δ (1 / 2) w (by norm_num) hw
  have e : (1 / 2 : ℝ) / (2 + 1 / 2) = 1 / 5 := by norm_num
  rw [e] at h
  rw [h]; constructor <;> intro h' <;> linarith

theorem harvey_half_floor_sixth : (1 / 2 + 0 : ℝ) / (2 + 1 / 2 + 1 / 2) = 1 / 6 := by norm_num

/-- **Unique minimiser of the added-floor cost** (`w > 0`, `α > 0`; for `α = 0` the pair floor
`a` is not pinned, so positivity is needed): if the cost reaches the
optimum then all three floors sit at it — the new floor binds *after* the rebalance. -/
theorem floor_unique_minimizer (γ δ α w a b c : ℝ) (hα : 0 < α) (hw : 0 < w)
    (h : floorExp γ δ α w a b c ≤ (γ + δ) / (2 + α + w)) :
    a = (γ + δ) / (2 + α + w) ∧ b = (γ + δ) / (2 + α + w) ∧ c = (γ + δ) / (2 + α + w) := by
  set t := (γ + δ) / (2 + α + w)
  have hpos : 0 < 2 + α + w := by linarith
  have ht : t * (2 + α + w) = γ + δ := by simp only [t]; field_simp
  unfold floorExp at h
  simp only [max_le_iff] at h
  obtain ⟨ha, hb, hc, hI⟩ := h
  have h1 : α * a ≤ α * t := mul_le_mul_of_nonneg_left ha hα.le
  have h2 : w * c ≤ w * t := mul_le_mul_of_nonneg_left hc hw.le
  have hb' : b = t := by nlinarith
  have hc' : c = t := by
    have : w * c = w * t := by nlinarith
    exact mul_left_cancel₀ hw.ne' this
  refine ⟨?_, hb', hc'⟩
  have : α * a = α * t := by nlinarith
  exact mul_left_cancel₀ hα.ne' this

/-! ## The faithful model: a new floor must enter **both** certificates

In the faithful model (`Logic.HarveyFaithfulSlackness`) Algorithm 4.3 Step 2 adds the
`M`-leg `(N/r)^{1/4}`.  A new floor `s = N^c` may enter the interior with weight `w` and the
`M`-leg with weight `θ`. -/

/-- Faithful four-leg exponent with a new floor `c` coupled to the `M`-leg (weight `θ`) and to
the interior (weight `w`). -/
noncomputable def faithfulFloorExp (θ w a b c : ℝ) : ℝ :=
  max ((1 - a) / 4 - θ * c) (max a (max b (max c (1 / 2 - a / 2 - b - w * c))))

/-- **Faithful add-a-floor law (lower bound).** For `θ, w ≥ 0`, the cost is at least both
`1/(5 + 4θ)` (the `{M-leg, r, s}` certificate) and `1/(5 + 2w)` (the
`{interior, r, m, s}` certificate). -/
theorem faithful_floor_lower (θ w a b c : ℝ) (hθ : 0 ≤ θ) (hw : 0 ≤ w) :
    1 / (5 + 4 * θ) ≤ faithfulFloorExp θ w a b c ∧ 1 / (5 + 2 * w) ≤ faithfulFloorExp θ w a b c := by
  set T := faithfulFloorExp θ w a b c
  have hM : (1 - a) / 4 - θ * c ≤ T := le_max_left _ _
  have ha : a ≤ T := le_trans (le_max_left _ _) (le_max_right _ _)
  have hb : b ≤ T := le_trans (le_trans (le_max_left _ _) (le_max_right _ _)) (le_max_right _ _)
  have hc : c ≤ T := le_trans (le_trans (le_trans (le_max_left _ _) (le_max_right _ _))
    (le_max_right _ _)) (le_max_right _ _)
  have hI : 1 / 2 - a / 2 - b - w * c ≤ T := le_trans (le_trans (le_trans (le_max_right _ _)
    (le_max_right _ _)) (le_max_right _ _)) (le_max_right _ _)
  have h1 : θ * c ≤ θ * T := mul_le_mul_of_nonneg_left hc hθ
  have h2 : w * c ≤ w * T := mul_le_mul_of_nonneg_left hc hw
  constructor
  · rw [div_le_iff₀ (by linarith)]; nlinarith
  · rw [div_le_iff₀ (by linarith)]; nlinarith

/-- **Beating `1/5` in the faithful model needs the new floor in both legs.** If the faithful
cost drops strictly below `1/5` at some point, then `θ > 0` **and** `w > 0`. -/
theorem faithful_floor_needs_both (θ w a b c : ℝ) (hθ : 0 ≤ θ) (hw : 0 ≤ w)
    (h : faithfulFloorExp θ w a b c < 1 / 5) : 0 < θ ∧ 0 < w := by
  obtain ⟨h1, h2⟩ := faithful_floor_lower θ w a b c hθ hw
  constructor
  · by_contra hθ0
    have : θ = 0 := le_antisymm (not_lt.mp hθ0) hθ
    subst this; norm_num at h1; linarith
  · by_contra hw0
    have : w = 0 := le_antisymm (not_lt.mp hw0) hw
    subst this; norm_num at h2; linarith

/-- **Reaching `1/6` faithfully needs `θ ≥ 1/4` and `w ≥ 1/2`** ... -/
theorem faithful_floor_sixth_needs (θ w a b c : ℝ) (hθ : 0 ≤ θ) (hw : 0 ≤ w)
    (h : faithfulFloorExp θ w a b c ≤ 1 / 6) : 1 / 4 ≤ θ ∧ 1 / 2 ≤ w := by
  obtain ⟨h1, h2⟩ := faithful_floor_lower θ w a b c hθ hw
  have e1 : 1 / (5 + 4 * θ) ≤ 1 / 6 := le_trans h1 h
  have e2 : 1 / (5 + 2 * w) ≤ 1 / 6 := le_trans h2 h
  rw [div_le_div_iff₀ (by linarith) (by norm_num)] at e1 e2
  constructor <;> linarith

/-- ... **and these suffice:** at `θ = 1/4`, `w = 1/2` all five legs equal `1/6` at
`a = b = c = 1/6`. -/
theorem faithful_floor_sixth_attained :
    faithfulFloorExp (1 / 4) (1 / 2) (1 / 6) (1 / 6) (1 / 6) = 1 / 6 := by
  unfold faithfulFloorExp; norm_num

end Bridges.HarveyMLegClosed