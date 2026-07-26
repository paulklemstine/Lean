import Mathlib

/-!
# Row-exchange under eventual contraction for the infinite asymmetric five-vertex half-strip

We model the row-to-row *transfer operators* of an (asymmetric) five-vertex model on a
semi-infinite strip of width `5` as elements of the normed ring `TM = Matrix (Fin 5) (Fin 5) ℝ`,
equipped with the `L∞` operator norm (a complete `NormOneClass` normed algebra, hence
`HasSummableGeomSeries`).

Two mechanisms drive the theory:

* **Eventual contraction.** A sequence of transfer operators `M : ℕ → R` is *eventually
  contracting* if there is a uniform bound `‖M k‖ ≤ c < 1` for all `k ≥ N`.  The accumulated
  half-strip product `prodDown M m = M (m-1) * ⋯ * M 0` then norm-collapses: its norm tends
  to `0`.  This is the statistical-mechanics statement that, far up the half-strip, correlations
  decay and the row-product is washed out.

* **Row exchange.** Swapping two vertex rows `i, j` is left/right conjugation by the permutation
  matrix `S = (swap i j).permMatrix`, an involution `S * S = 1`.  When a transfer operator `A`
  is *symmetric under the swap* (`S * A = A * S`), the eventually-contracting resolvent
  `(1 - A)⁻¹ = ∑' n, Aⁿ` inherits the symmetry: `S * (1 - A)⁻¹ * S = (1 - A)⁻¹`.

The main results are stated abstractly for a complete normed ring `R` and then specialized to the
five-vertex transfer ring `TM`.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer).  The eventual-contraction regime should make every "symmetry of the
local Boltzmann weights" survive to the macroscopic resolvent.  Bold form: *any* involutive
symmetry commuting with the (contracting) transfer operator is exactly preserved by its geometric
resolvent — there is no spontaneous symmetry breaking inside the contraction radius `‖A‖ < 1`.

EXPERIMENT (Experimenter).  The resolvent is `∑' n, Aⁿ` (`hasSum_geom_series_inverse`).  Conjugation
`y ↦ S y S` is a *continuous additive map* (`AddMonoidHom` + `Continuous.mul`), so it commutes with
`HasSum` via `HasSum.map`.  On each power, `S Aⁿ S = Aⁿ` because `S A = A S` lets `S` slide through
to meet its partner (`S S = 1`).  Uniqueness of sums (`HasSum.unique`) then transports the fixed
point from the summands to the sum.  This avoids ever inverting a matrix explicitly.

EXPERIMENT (Experimenter, contraction).  For the half-strip product we accumulate on the *left*:
`prodDown M (m+1) = M m * prodDown M m`.  Submultiplicativity gives the geometric tail bound
`‖prodDown M m‖ ≤ ‖prodDown M N‖ * c^(m-N)` for `m ≥ N` (induction via `Nat.le_induction`), and
`c^(m-N) → 0` since `0 ≤ c < 1`.  A squeeze finishes it.

INSIGHT.  The two phenomena combine: the contraction guarantees the resolvent *exists* (summable),
and the symmetry argument shows it is row-exchange invariant.  Eventual contraction also makes the
row-exchanged product `S * prodDown M m` vanish (left-multiplying by the norm-`≤1` permutation
matrix cannot rescue a sequence that already tends to `0`).

ITERATION 2 (Synthesizer).  The involution hypothesis `S * S = 1` is *not* essential to the symmetry
argument: the same `HasSum.map`/uniqueness proof goes through for conjugation by an arbitrary unit
`u` (`conj_unit_inverse_one_sub_eq`), so a whole symmetry *group* of commuting permutations fixes the
resolvent, not just a single transposition.  Separately, the resolvent is quantitatively tame:
`norm_inverse_one_sub_le` gives `‖(1 - A)⁻¹‖ ≤ (1 - ‖A‖)⁻¹` by dominating the operator geometric
series termwise by the scalar one (`norm_tsum_le_tsum_norm`, `norm_pow_le`, `tsum_geometric_of_lt_one`).
Since `‖rowExchange i j‖ = 1`, this bound is itself row-exchange invariant.

FAILURE ANALYSIS.  Matrices carry *no* default `NormedRing` instance in Mathlib (several inequivalent
operator norms exist); we must `attribute [local instance] Matrix.linftyOpNormedRing
Matrix.linftyOpNormedAlgebra`.  Also `tsum_geometric_of_norm_lt_one` is only for *division* rings;
for the noncommutative matrix ring we use `hasSum_geom_series_inverse`/`geom_series_eq_inverse`
(value `Ring.inverse (1 - A)`), valid for any complete normed ring.
-/

open scoped Matrix

namespace FiveVertexRowExchange

/-! ## Abstract layer: eventual contraction and conjugation symmetry in a complete normed ring -/

section General

variable {R : Type*} [NormedRing R] [CompleteSpace R]

/-- An involution conjugating a commuting element fixes each of its powers:
`u * xⁿ * u = xⁿ` whenever `u * u = 1` and `u * x = x * u`. -/
omit [CompleteSpace R] in
theorem conj_pow_eq (u x : R) (hu : u * u = 1) (hc : u * x = x * u) (n : ℕ) :
    u * x ^ n * u = x ^ n := by
  have hci : u * x ^ n = x ^ n * u := (Commute.pow_right (Commute.symm hc).symm n)
  rw [hci, mul_assoc, hu, mul_one]

/-- **Row-exchange invariance of the eventually-contracting resolvent (resolvent form).**
If `u` is an involution (`u * u = 1`) commuting with a contraction `x` (`‖x‖ < 1`,
`u * x = x * u`), then conjugating the resolvent `(1 - x)⁻¹ = Ring.inverse (1 - x)` by `u`
leaves it unchanged. -/
theorem conj_inverse_one_sub_eq (u x : R) (hu : u * u = 1) (hc : u * x = x * u)
    (h : ‖x‖ < 1) :
    u * Ring.inverse (1 - x) * u = Ring.inverse (1 - x) := by
  have key : HasSum (fun i => x ^ i) (Ring.inverse (1 - x)) := hasSum_geom_series_inverse x h
  let g : R →+ R :=
    { toFun := fun y => u * y * u
      map_zero' := by simp
      map_add' := fun a b => by simp [mul_add, add_mul] }
  have hg : Continuous g := (continuous_const.mul continuous_id).mul continuous_const
  have hmap := key.map g hg
  have heq : (g ∘ fun i => x ^ i) = (fun i => x ^ i) := by
    funext i
    simp only [Function.comp, g, AddMonoidHom.coe_mk, ZeroHom.coe_mk]
    exact conj_pow_eq u x hu hc i
  rw [heq] at hmap
  have hfix : g (Ring.inverse (1 - x)) = Ring.inverse (1 - x) := hmap.unique key
  simpa [g] using hfix

/-- **Row-exchange invariance of the eventually-contracting resolvent (tsum form).** -/
theorem conj_tsum_geom_eq (u x : R) (hu : u * u = 1) (hc : u * x = x * u) (h : ‖x‖ < 1) :
    u * (∑' n : ℕ, x ^ n) * u = ∑' n : ℕ, x ^ n := by
  rw [geom_series_eq_inverse x h]
  exact conj_inverse_one_sub_eq u x hu hc h

/-- **Unit-conjugation invariance (general symmetry group form, cf. FUTURE_DIRECTIONS C1).**
Dropping the involution hypothesis: for *any* unit `u` commuting with a contraction `x`,
conjugation by `u` fixes the resolvent `(1 - x)⁻¹`.  Specializing to a self-inverse permutation
matrix recovers `conj_inverse_one_sub_eq`; specializing to a generating set of a symmetry subgroup
yields invariance under the whole group. -/
theorem conj_unit_inverse_one_sub_eq (u : Rˣ) (x : R) (hc : (u : R) * x = x * u)
    (h : ‖x‖ < 1) :
    (u : R) * Ring.inverse (1 - x) * (↑u⁻¹) = Ring.inverse (1 - x) := by
  have key : HasSum (fun i => x ^ i) (Ring.inverse (1 - x)) := hasSum_geom_series_inverse x h
  let g : R →+ R :=
    { toFun := fun y => (u : R) * y * (↑u⁻¹)
      map_zero' := by simp
      map_add' := fun a b => by simp [mul_add, add_mul] }
  have hg : Continuous g := (continuous_const.mul continuous_id).mul continuous_const
  have hmap := key.map g hg
  have heq : (g ∘ fun i => x ^ i) = (fun i => x ^ i) := by
    funext i
    simp only [Function.comp, g, AddMonoidHom.coe_mk, ZeroHom.coe_mk]
    have hci : (u : R) * x ^ i = x ^ i * u := (Commute.pow_right (Commute.symm hc).symm i)
    rw [hci, mul_assoc]; simp
  rw [heq] at hmap
  simpa [g] using hmap.unique key

/-- **Neumann norm bound on the eventually-contracting resolvent (cf. FUTURE_DIRECTIONS C2).**
The resolvent of a contraction is controlled by the scalar geometric bound:
`‖(1 - x)⁻¹‖ ≤ (1 - ‖x‖)⁻¹`. -/
theorem norm_inverse_one_sub_le [NormOneClass R] (x : R) (h : ‖x‖ < 1) :
    ‖Ring.inverse (1 - x)‖ ≤ (1 - ‖x‖)⁻¹ := by
  rw [← geom_series_eq_inverse x h]
  have hgeo : Summable (fun n => ‖x‖ ^ n) := summable_geometric_of_lt_one (norm_nonneg x) h
  have hsummN : Summable (fun n => ‖x ^ n‖) :=
    hgeo.of_nonneg_of_le (fun _ => norm_nonneg _) (fun n => norm_pow_le x n)
  calc ‖∑' n : ℕ, x ^ n‖ ≤ ∑' n : ℕ, ‖x ^ n‖ := norm_tsum_le_tsum_norm hsummN
    _ ≤ ∑' n : ℕ, ‖x‖ ^ n := Summable.tsum_le_tsum (fun n => norm_pow_le x n) hsummN hgeo
    _ = (1 - ‖x‖)⁻¹ := tsum_geometric_of_lt_one (norm_nonneg x) h

/-- The accumulated half-strip transfer product, growing upward (new rows multiplied on the left). -/
def prodDown (M : ℕ → R) : ℕ → R
  | 0 => 1
  | (m + 1) => M m * prodDown M m

omit [CompleteSpace R] in
@[simp] theorem prodDown_zero (M : ℕ → R) : prodDown M 0 = 1 := rfl

omit [CompleteSpace R] in
@[simp] theorem prodDown_succ (M : ℕ → R) (m : ℕ) :
    prodDown M (m + 1) = M m * prodDown M m := rfl

/-- Geometric tail bound on the half-strip product norm under eventual contraction. -/
omit [CompleteSpace R] in
theorem norm_prodDown_le_tail (M : ℕ → R) (c : ℝ) (N : ℕ) (hc0 : 0 ≤ c)
    (hN : ∀ k, N ≤ k → ‖M k‖ ≤ c) :
    ∀ m, N ≤ m → ‖prodDown M m‖ ≤ ‖prodDown M N‖ * c ^ (m - N) := by
  intro m hm; induction' hm with m hm ih <;> simp_all +decide
  exact le_trans ( norm_mul_le _ _ ) ( by rw [ Nat.succ_sub hm, pow_succ' ] ; nlinarith [ hN m hm, norm_nonneg ( prodDown M m ) ] )

/-- **Eventual contraction collapses the half-strip product.**
If the transfer operators satisfy a uniform contraction bound `‖M k‖ ≤ c < 1` for all `k ≥ N`,
then the accumulated product norm tends to `0`. -/
omit [CompleteSpace R] in
theorem prodDown_tendsto_zero (M : ℕ → R) (c : ℝ) (N : ℕ) (hc : c < 1)
    (hN : ∀ k, N ≤ k → ‖M k‖ ≤ c) :
    Filter.Tendsto (fun m => ‖prodDown M m‖) Filter.atTop (nhds 0) := by
  -- By the geometric tail bound, we have ‖prodDown M m‖ ≤ ‖prodDown M N‖ * c ^ (m - N) for all m ≥ N.
  have h_tail : ∀ m ≥ N, ‖prodDown M m‖ ≤ ‖prodDown M N‖ * c ^ (m - N) := by
    convert norm_prodDown_le_tail M c N _ hN;
    exact le_trans ( norm_nonneg _ ) ( hN N le_rfl );
  refine' squeeze_zero_norm' _ _;
  exacts [ fun n => ‖prodDown M N‖ * c ^ ( n - N ), Filter.eventually_atTop.2 ⟨ N, fun n hn => by simpa using h_tail n hn ⟩, by simpa using tendsto_const_nhds.mul ( tendsto_pow_atTop_nhds_zero_of_lt_one ( show 0 ≤ c by exact le_trans ( norm_nonneg _ ) ( hN N le_rfl ) ) hc |> Filter.Tendsto.comp <| Filter.tendsto_sub_atTop_nat N ) ]

end General

/-! ## Concrete layer: the five-vertex transfer ring `TM = Matrix (Fin 5) (Fin 5) ℝ` -/

section FiveVertex

open Matrix
attribute [local instance] Matrix.linftyOpNormedRing Matrix.linftyOpNormedAlgebra

/-- The `5` vertex states of a single column of the half-strip. -/
abbrev V : Type := Fin 5

/-- The transfer ring: real `5 × 5` matrices with the `L∞` operator norm. -/
abbrev TM : Type := Matrix V V ℝ

/-- Exchanging rows `i` and `j`: conjugation by this permutation matrix swaps the two vertex rows. -/
def rowExchange (i j : V) : TM := (Equiv.swap i j).permMatrix ℝ

/-- Row exchange is an involution. -/
@[simp] theorem rowExchange_involutive (i j : V) :
    rowExchange i j * rowExchange i j = 1 := by
  unfold rowExchange
  rw [← Matrix.permMatrix_mul, Equiv.swap_mul_self, Matrix.permMatrix_one]

/-- **Main theorem (five-vertex resolvent symmetry).**
For a transfer operator `A` with `‖A‖ < 1` that is symmetric under exchanging rows `i, j`
(`rowExchange i j * A = A * rowExchange i j`), the eventually-contracting resolvent
`(1 - A)⁻¹` is row-exchange invariant. -/
theorem rowExchange_resolvent_invariant (A : TM) (i j : V)
    (hcomm : rowExchange i j * A = A * rowExchange i j) (h : ‖A‖ < 1) :
    rowExchange i j * Ring.inverse (1 - A) * rowExchange i j = Ring.inverse (1 - A) :=
  conj_inverse_one_sub_eq (rowExchange i j) A (rowExchange_involutive i j) hcomm h

/-- **Five-vertex resolvent norm bound.** `‖(1 - A)⁻¹‖ ≤ (1 - ‖A‖)⁻¹` for a contraction `A`;
this bound is row-exchange invariant because `‖rowExchange i j‖ = 1`. -/
theorem rowExchange_resolvent_norm_le (A : TM) (h : ‖A‖ < 1) :
    ‖Ring.inverse (1 - A)‖ ≤ (1 - ‖A‖)⁻¹ :=
  norm_inverse_one_sub_le A h

/-- The same symmetry stated for the explicit geometric series `∑' n, Aⁿ`. -/
theorem rowExchange_geom_series_invariant (A : TM) (i j : V)
    (hcomm : rowExchange i j * A = A * rowExchange i j) (h : ‖A‖ < 1) :
    rowExchange i j * (∑' n : ℕ, A ^ n) * rowExchange i j = ∑' n : ℕ, A ^ n :=
  conj_tsum_geom_eq (rowExchange i j) A (rowExchange_involutive i j) hcomm h

/-- **Eventual contraction on the five-vertex half-strip.**
If a sequence of transfer operators is eventually contracting, the accumulated half-strip product
norm-collapses to `0`. -/
theorem transferProduct_vanishes (M : ℕ → TM) (c : ℝ) (N : ℕ) (hc : c < 1)
    (hN : ∀ k, N ≤ k → ‖M k‖ ≤ c) :
    Filter.Tendsto (fun m => ‖prodDown M m‖) Filter.atTop (nhds 0) :=
  prodDown_tendsto_zero M c N hc hN

/-- Row-exchanging the (vanishing) accumulated product still vanishes: the row-exchanged
half-strip product norm tends to `0` as well. -/
theorem rowExchange_transferProduct_vanishes (M : ℕ → TM) (c : ℝ) (N : ℕ) (i j : V)
    (hc : c < 1) (hN : ∀ k, N ≤ k → ‖M k‖ ≤ c) :
    Filter.Tendsto (fun m => ‖rowExchange i j * prodDown M m‖) Filter.atTop (nhds 0) := by
  have hmul : Filter.Tendsto (fun m => ‖rowExchange i j‖ * ‖prodDown M m‖) Filter.atTop (nhds 0) := by
    simpa using (transferProduct_vanishes M c N hc hN).const_mul ‖rowExchange i j‖
  exact squeeze_zero (fun m => norm_nonneg _) (fun m => norm_mul_le _ _) hmul

end FiveVertex

end FiveVertexRowExchange