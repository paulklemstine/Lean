import Mathlib

/-!
# Moonshine beyond the j-function II: higher moments of trace series and the
# Laurent-normalization obstruction

This file continues the research thread begun in `Catalog/Novelty/MonsterMoonshineBridge.lean`,
which proved the *first moment* identity (Burnside's lemma, gradewise)

  `∑_{g ∈ G} |(X n)^g| = |G| · #(X n / G)`,

i.e. that the average of the fixed-point ("permutation-character") q-series of a graded
finite `G`-set is the orbit-counting series.

Four genuinely new directions are developed here: the moment hierarchy and its rigidity, the
Laurent-normalization obstruction, an information-preserving alternative to the product
aggregate, and the two extremes of the hierarchy (trivial, free and 2-transitive actions).

## 1. The full moment hierarchy of trace series

The first moment only sees the number of orbits.  We prove that *every* moment of the family
of fixed-point series is again an orbit count, for the diagonal action on `k`-tuples:

  `∑_{g ∈ G} |X^g|^k = |G| · #((Fin k → X) / G)`   (`sum_fixedPoints_pow_eq_orbits_mul_card`)

For `k = 2` this is the classical statement that the rank of a permutation group (number of
orbitals) is the squared norm of its permutation character.  Combined with the power-mean
inequality this yields a purely combinatorial consequence which is *not* visible at the level
of the first moment alone:

  `#(X/G)^k ≤ #((Fin k → X)/G)`   (`orbits_pow_le_orbits_pi`).

Gradewise, this says the coefficientwise `k`-th power of the moonshine-type trace series again
averages to an orbit-counting series: the family of trace series carries an infinite hierarchy
of enumerative information, of which Burnside's lemma is only the first layer.

## 2. Why the "product over all classes" claim fails: a pole-order obstruction

McKay--Thompson series are normalized as `q⁻¹ + O(q)`, i.e. as Laurent series of order `-1`.
We model these by Hahn series `HahnSeries ℤ ℤ` and prove that a product over a finite index
set of such normalized series has order exactly `-#s`; in particular for `194` conjugacy
classes the product has a pole of order `194` at the cusp and is therefore *not* holomorphic
there (`prod_normalized_not_holomorphic`).  We also show that the unlabeled product aggregate
is not injective on families (`prod_aggregate_not_injective`), so it cannot reconstruct
class-indexed data.  These are the precise formal versions of the objections recorded in
`FUTURE_DIRECTIONS.md` of the previous cycle.

## 3. What survives the obstruction

The trace series are constructed as honest `q⁻¹`-normalized Laurent series and their average is
identified with the normalized orbit series (`sum_traceLaurent_eq_card_smul_orbitLaurent`);
multiplying the product by `q^{m}` restores order `0` (`orderTop_renormalized_prod`); and the
interleaved aggregate (`interleave`) is an injective scalar encoding of a whole class-indexed
family (`interleave_injective`), in contrast with the product.

## 4. Extremes of the moment hierarchy

Equality in the moment inequality characterizes the trivial action
(`orbits_sq_eq_orbitals_iff_trivial`, with a quantitative form `rigidity_quantitative`);
maximality of a single moment characterizes free actions (`free_iff_orbits_pi`), with the
regular action computed exactly (`card_orbits_pi_regular`); and the value `2|G|` of the second
moment characterizes 2-transitivity (`sum_fixedPoints_sq_eq_two_mul_card_iff`).
-/

namespace MoonshineMoments

open MulAction

/-! ## Part 1: Burnside in `Nat.card` form -/

section Burnside

variable (G : Type*) [Group G] [Fintype G] (X : Type*) [MulAction G X] [Finite X]

/-- Burnside's orbit-counting lemma, stated with `Nat.card` so that no auxiliary `Fintype`
instances have to be carried around. -/
theorem sum_card_fixedBy_eq_orbits_mul_card :
    ∑ g : G, Nat.card (fixedBy X g) = Nat.card (orbitRel.Quotient G X) * Nat.card G := by
  classical
  letI := Fintype.ofFinite X
  letI : ∀ g : G, Fintype (fixedBy X g) := fun g => Fintype.ofFinite _
  letI : Fintype (orbitRel.Quotient G X) := Fintype.ofFinite _
  simpa [Nat.card_eq_fintype_card] using
    MulAction.sum_card_fixedBy_eq_card_orbits_mul_card_group G X

end Burnside

/-! ## Part 2: the moment hierarchy -/

section Moments

variable {G : Type*} [Group G] {X : Type*} [MulAction G X]

/-- The fixed points of `g` on the `k`-fold power `Fin k → X` (diagonal action) are exactly the
`k`-tuples of fixed points of `g` on `X`. -/
def fixedByPiEquiv (k : ℕ) (g : G) :
    fixedBy (Fin k → X) g ≃ (Fin k → fixedBy X g) where
  toFun x i := ⟨x.1 i, congrFun x.2 i⟩
  invFun y := ⟨fun i => (y i).1, funext fun i => (y i).2⟩
  left_inv _ := by ext i; rfl
  right_inv _ := by ext i; rfl

/-- Counting form of `fixedByPiEquiv`: fixed points multiply under taking powers of the
`G`-set. -/
theorem card_fixedBy_pi (k : ℕ) (g : G) [Finite X] :
    Nat.card (fixedBy (Fin k → X) g) = Nat.card (fixedBy X g) ^ k := by
  simp [Nat.card_congr (fixedByPiEquiv k g), Nat.card_fun]

variable (G X)

/-- **Moment hierarchy of the trace/fixed-point series.**  For every `k`, the `k`-th moment of
the fixed-point counting function over the group is `|G|` times the number of orbits on
`k`-tuples.  `k = 1` is Burnside's lemma; `k = 2` computes the rank (number of orbitals) of the
permutation action. -/
theorem sum_fixedPoints_pow_eq_orbits_mul_card [Fintype G] [Finite X] (k : ℕ) :
    ∑ g : G, Nat.card (fixedBy X g) ^ k =
      Nat.card (orbitRel.Quotient G (Fin k → X)) * Nat.card G := by
  have h := sum_card_fixedBy_eq_orbits_mul_card G (Fin k → X)
  simp only [card_fixedBy_pi] at h
  exact h

/-- The second moment: the squared norm of the permutation character counts orbits on pairs. -/
theorem sum_fixedPoints_sq_eq_orbitals_mul_card [Fintype G] [Finite X] :
    ∑ g : G, Nat.card (fixedBy X g) ^ 2 =
      Nat.card (orbitRel.Quotient G (Fin 2 → X)) * Nat.card G :=
  sum_fixedPoints_pow_eq_orbits_mul_card G X 2

end Moments

/-! ## Part 3: a power-mean consequence for orbit counts -/

section PowerMean

variable {G : Type*} [Group G] [Fintype G] {X : Type*} [MulAction G X] [Finite X]

/-- Power-mean inequality applied to the fixed-point counting function. -/
private theorem pow_sum_le_card_pow_mul_sum_pow (k : ℕ) (a : G → ℕ) :
    (∑ g : G, a g) ^ (k + 1) ≤ (Fintype.card G) ^ k * ∑ g : G, a g ^ (k + 1) := by
  have hpos : (0 : ℝ) < (Finset.univ : Finset G).card := by
    simpa [Finset.card_univ] using
      (Nat.cast_pos (α := ℝ)).2 (Fintype.card_pos_iff.2 ⟨(1 : G)⟩)
  have h := pow_sum_div_card_le_sum_pow (s := (Finset.univ : Finset G))
    (f := fun g => (a g : ℝ)) (fun i _ => by positivity) k
  rw [div_le_iff₀ (by positivity)] at h
  have h' : ((∑ g : G, a g : ℕ) : ℝ) ^ (k + 1)
      ≤ ((Fintype.card G : ℕ) : ℝ) ^ k * ((∑ g : G, a g ^ (k + 1) : ℕ) : ℝ) := by
    push_cast
    calc (∑ g : G, (a g : ℝ)) ^ (k + 1)
        ≤ (∑ g : G, (a g : ℝ) ^ (k + 1)) * ((Finset.univ : Finset G).card : ℝ) ^ k := h
      _ = ((Finset.univ : Finset G).card : ℝ) ^ k * ∑ g : G, (a g : ℝ) ^ (k + 1) := by ring
      _ = ((Fintype.card G : ℕ) : ℝ) ^ k * ∑ g : G, (a g : ℝ) ^ (k + 1) := by
            simp [Finset.card_univ]
  exact_mod_cast h'

/-- **Superadditivity of orbit counting under powers.**  The number of orbits on `k`-tuples is
at least the `k`-th power of the number of orbits.  Equivalently: the higher moments of the
trace series carry strictly more enumerative content than the first moment can bound from
above. -/
theorem orbits_pow_le_orbits_pi (k : ℕ) :
    Nat.card (orbitRel.Quotient G X) ^ (k + 1)
      ≤ Nat.card (orbitRel.Quotient G (Fin (k + 1) → X)) := by
  set N := Fintype.card G with hN
  have hNpos : 0 < N := Fintype.card_pos_iff.2 ⟨(1 : G)⟩
  have hcard : Nat.card G = N := by simp [hN, Nat.card_eq_fintype_card]
  have h1 := sum_card_fixedBy_eq_orbits_mul_card G X
  have hk := sum_fixedPoints_pow_eq_orbits_mul_card G X (k + 1)
  have hpm := pow_sum_le_card_pow_mul_sum_pow (G := G) k (fun g => Nat.card (fixedBy X g))
  rw [h1, hk, hcard] at hpm
  -- `(r₁ * N)^(k+1) ≤ N^k * (r_{k+1} * N)`
  have : Nat.card (orbitRel.Quotient G X) ^ (k + 1) * N ^ (k + 1)
      ≤ Nat.card (orbitRel.Quotient G (Fin (k + 1) → X)) * N ^ (k + 1) := by
    calc Nat.card (orbitRel.Quotient G X) ^ (k + 1) * N ^ (k + 1)
        = (Nat.card (orbitRel.Quotient G X) * N) ^ (k + 1) := by rw [mul_pow]
      _ ≤ N ^ k * (Nat.card (orbitRel.Quotient G (Fin (k + 1) → X)) * N) := hpm
      _ = Nat.card (orbitRel.Quotient G (Fin (k + 1) → X)) * N ^ (k + 1) := by ring
  exact Nat.le_of_mul_le_mul_right this (by positivity)

end PowerMean

/-! ## Part 4: graded (q-series) form of the moment hierarchy -/

section Graded

variable (G : Type*) [Group G] [Fintype G]
variable (X : ℕ → Type*) [∀ n, MulAction G (X n)] [∀ n, Finite (X n)]

/-- The fixed-point (McKay--Thompson-type) q-series attached to `g`, as a coefficient
function. -/
noncomputable def traceSeries (g : G) : ℕ → ℕ := fun n => Nat.card (fixedBy (X n) g)

/-- The orbit-counting q-series of the `k`-fold power of the graded action. -/
noncomputable def orbitSeriesPow (k : ℕ) : ℕ → ℕ :=
  fun n => Nat.card (orbitRel.Quotient G (Fin k → X n))

/-- **Graded moment identity.**  Summing the coefficientwise `k`-th powers of all trace series
gives `|G|` times the orbit-counting series of the `k`-fold power action.  For `k = 1` this is
the connector proved in the previous cycle; for `k ≥ 2` it is new information about the same
family of series. -/
theorem sum_traceSeries_pow_eq (k : ℕ) :
    (fun n => ∑ g : G, traceSeries G X g n ^ k) =
      fun n => Nat.card G * orbitSeriesPow G X k n := by
  funext n
  rw [mul_comm]
  exact sum_fixedPoints_pow_eq_orbits_mul_card G (X n) k

/-- Gradewise superadditivity: the orbit series of the `(k+1)`-st power action dominates the
`(k+1)`-st power of the orbit series. -/
theorem orbitSeries_pow_le (k : ℕ) (n : ℕ) :
    Nat.card (orbitRel.Quotient G (X n)) ^ (k + 1) ≤ orbitSeriesPow G X (k + 1) n :=
  orbits_pow_le_orbits_pi k

end Graded

/-! ## Part 5: rigidity — the second moment degenerates only for the trivial action -/

section Rigidity

variable {G : Type*} [Group G] [Fintype G] {X : Type*} [MulAction G X] [Finite X]

/-- The Lagrange-type identity behind the equality case of Cauchy--Schwarz. -/
private theorem sum_sq_diff_identity {ι : Type*} [Fintype ι] (a : ι → ℤ) :
    ∑ g : ι, ∑ h : ι, (a g - a h) ^ 2
      = 2 * (Fintype.card ι) * (∑ g : ι, a g ^ 2) - 2 * (∑ g : ι, a g) ^ 2 := by
  have h : ∀ g h : ι, (a g - a h) ^ 2 = a g ^ 2 - 2 * (a g * a h) + a h ^ 2 := by
    intros; ring
  simp_rw [h, Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum, ← Finset.sum_mul]
  simp only [Finset.sum_const, Finset.card_univ, nsmul_eq_mul, ← Finset.mul_sum]
  ring

/-- Equality case of the Cauchy--Schwarz inequality over a finite index type: if the square of
the sum meets the bound, the summands are all equal. -/
theorem const_of_sq_sum_eq {ι : Type*} [Fintype ι] (a : ι → ℕ)
    (heq : (∑ g : ι, a g) ^ 2 = Fintype.card ι * ∑ g : ι, a g ^ 2) (g h : ι) :
    a g = a h := by
  have hz : ∑ g : ι, ∑ h : ι, ((a g : ℤ) - a h) ^ 2 = 0 := by
    rw [sum_sq_diff_identity]
    have hc : ((∑ g : ι, a g : ℕ) : ℤ) ^ 2 = (Fintype.card ι : ℤ) * ∑ g : ι, (a g : ℤ) ^ 2 := by
      exact_mod_cast congrArg (Nat.cast : ℕ → ℤ) heq
    push_cast at hc
    linarith [hc]
  have hnn : ∀ g ∈ (Finset.univ : Finset ι), (0 : ℤ) ≤ ∑ h : ι, ((a g : ℤ) - a h) ^ 2 :=
    fun _ _ => Finset.sum_nonneg fun _ _ => sq_nonneg _
  have h1 := (Finset.sum_eq_zero_iff_of_nonneg hnn).1 hz g (Finset.mem_univ g)
  have h2 := (Finset.sum_eq_zero_iff_of_nonneg
    (fun h _ => sq_nonneg ((a g : ℤ) - a h))).1 h1 h (Finset.mem_univ h)
  have hgh : (a g : ℤ) = a h := by nlinarith [h2]
  exact_mod_cast hgh

omit [Fintype G] in
/-- If `g` fixes as many points as the whole set has, it acts as the identity. -/
theorem smul_eq_self_of_card_fixedBy (g : G)
    (h : Nat.card (fixedBy X g) = Nat.card X) (x : X) : g • x = x := by
  have h2 : (fixedBy X g).ncard = Nat.card X := by rw [Nat.card_coe_set_eq] at h; exact h
  have hu : fixedBy X g = Set.univ := (Set.eq_univ_iff_ncard _).mpr h2
  have hx : x ∈ fixedBy X g := hu ▸ Set.mem_univ x
  simpa using hx

omit [Fintype G] [Finite X] in
/-- The identity fixes everything. -/
theorem card_fixedBy_one : Nat.card (fixedBy X (1 : G)) = Nat.card X := by
  have h : fixedBy X (1 : G) = Set.univ := by ext x; simp
  rw [h]
  simp

/-- **Rigidity of the moment inequality.**  The bound `#(X/G)² ≤ #((Fin 2 → X)/G)` is an
equality precisely for the trivial action.  Hence the second moment of the family of trace
series strictly refines the first moment for every nontrivial action: these series carry
information invisible to Burnside's lemma alone. -/
theorem orbits_sq_eq_orbitals_iff_trivial :
    Nat.card (orbitRel.Quotient G X) ^ 2
        = Nat.card (orbitRel.Quotient G (Fin 2 → X)) ↔ ∀ (g : G) (x : X), g • x = x := by
  set N := Fintype.card G with hNdef
  have hNpos : 0 < N := Fintype.card_pos_iff.2 ⟨(1 : G)⟩
  have hcard : Nat.card G = N := by simp [hNdef, Nat.card_eq_fintype_card]
  have h1 : ∑ g : G, Nat.card (fixedBy X g) = Nat.card (orbitRel.Quotient G X) * N := by
    rw [← hcard]; exact sum_card_fixedBy_eq_orbits_mul_card G X
  have h2 : ∑ g : G, Nat.card (fixedBy X g) ^ 2
      = Nat.card (orbitRel.Quotient G (Fin 2 → X)) * N := by
    rw [← hcard]; exact sum_fixedPoints_pow_eq_orbits_mul_card G X 2
  constructor
  · intro heq g x
    have hcs : (∑ g : G, Nat.card (fixedBy X g)) ^ 2
        = Fintype.card G * ∑ g : G, Nat.card (fixedBy X g) ^ 2 := by
      rw [h1, h2, ← hNdef, mul_pow, heq]
      ring
    have hconst := const_of_sq_sum_eq (fun g => Nat.card (fixedBy X g)) hcs g 1
    exact smul_eq_self_of_card_fixedBy g (by rw [hconst]; exact card_fixedBy_one) x
  · intro htriv
    have hfix : ∀ g : G, Nat.card (fixedBy X g) = Nat.card X := by
      intro g
      have hu : fixedBy X g = Set.univ := by
        ext x; simpa using htriv g x
      rw [hu]; simp
    simp only [hfix] at h1 h2
    rw [Finset.sum_const, Finset.card_univ, ← hNdef, smul_eq_mul] at h1 h2
    have e1 : Nat.card (orbitRel.Quotient G X) = Nat.card X := by
      have h1' : Nat.card X * N = Nat.card (orbitRel.Quotient G X) * N := by rw [← h1]; ring
      exact (Nat.eq_of_mul_eq_mul_right hNpos h1').symm
    have e2 : Nat.card (orbitRel.Quotient G (Fin 2 → X)) = Nat.card X ^ 2 := by
      have h2' : Nat.card X ^ 2 * N = Nat.card (orbitRel.Quotient G (Fin 2 → X)) * N := by
        rw [← h2]; ring
      exact (Nat.eq_of_mul_eq_mul_right hNpos h2').symm
    rw [e1, e2]

/-- **Quantitative rigidity.**  The Cauchy--Schwarz defect controls how far any single element
is from acting trivially: if `g` fixes few points, the second moment must exceed the square of
the first by a definite amount. -/
theorem rigidity_quantitative (g₀ : G) :
    ((Nat.card X : ℤ) - Nat.card (fixedBy X g₀)) ^ 2
      ≤ 2 * (Fintype.card G : ℤ) ^ 2 *
          ((Nat.card (orbitRel.Quotient G (Fin 2 → X)) : ℤ)
            - (Nat.card (orbitRel.Quotient G X) : ℤ) ^ 2) := by
  set N : ℤ := (Fintype.card G : ℤ) with hNdef
  set a : G → ℤ := fun g => (Nat.card (fixedBy X g) : ℤ) with hadef
  have hcard : (Nat.card G : ℤ) = N := by simp [hNdef, Nat.card_eq_fintype_card]
  have h1 : ∑ g : G, a g = (Nat.card (orbitRel.Quotient G X) : ℤ) * N := by
    have := sum_card_fixedBy_eq_orbits_mul_card G X
    have := congrArg (Nat.cast : ℕ → ℤ) this
    push_cast at this
    rw [hadef]
    rw [this, hcard]
  have h2 : ∑ g : G, a g ^ 2 = (Nat.card (orbitRel.Quotient G (Fin 2 → X)) : ℤ) * N := by
    have := sum_fixedPoints_pow_eq_orbits_mul_card G X 2
    have := congrArg (Nat.cast : ℕ → ℤ) this
    push_cast at this
    rw [hadef]
    rw [this, hcard]
  have hterm : (a 1 - a g₀) ^ 2 ≤ ∑ g : G, ∑ h : G, (a g - a h) ^ 2 := by
    calc (a 1 - a g₀) ^ 2 ≤ ∑ h : G, (a 1 - a h) ^ 2 :=
          Finset.single_le_sum (f := fun h => (a 1 - a h) ^ 2)
            (fun h _ => sq_nonneg _) (Finset.mem_univ g₀)
      _ ≤ ∑ g : G, ∑ h : G, (a g - a h) ^ 2 :=
          Finset.single_le_sum (f := fun g => ∑ h : G, (a g - a h) ^ 2)
            (fun g _ => Finset.sum_nonneg fun _ _ => sq_nonneg _) (Finset.mem_univ 1)
  rw [sum_sq_diff_identity, h1, h2, ← hNdef] at hterm
  have hone : a 1 = (Nat.card X : ℤ) := by rw [hadef]; exact_mod_cast congrArg _ card_fixedBy_one
  rw [hone] at hterm
  calc ((Nat.card X : ℤ) - Nat.card (fixedBy X g₀)) ^ 2 ≤ _ := hterm
    _ = 2 * N ^ 2 * ((Nat.card (orbitRel.Quotient G (Fin 2 → X)) : ℤ)
            - (Nat.card (orbitRel.Quotient G X) : ℤ) ^ 2) := by ring

end Rigidity

/-! ## Part 6: the Laurent normalization obstruction -/

section Laurent

/-- A Laurent-type `q`-series with integer coefficients, modelled as a Hahn series over `ℤ`. -/
abbrev QLaurent := HahnSeries ℤ ℤ

/-- The standard McKay--Thompson normalization: a series whose expansion begins with `q⁻¹`,
i.e. whose order at the cusp is exactly `-1`. -/
def IsMTNormalized (T : QLaurent) : Prop := T.orderTop = ((-1 : ℤ) : WithTop ℤ)

/-- Normalized series exist, and form a large family: `q⁻¹ + c` is normalized for every `c`.
This shows the hypotheses below are not vacuous. -/
theorem isMTNormalized_qinv_add (c : ℤ) :
    IsMTNormalized (HahnSeries.single (-1) 1 + HahnSeries.single 0 c) := by
  unfold IsMTNormalized
  rw [HahnSeries.orderTop_add_eq_left ?_]
  · simp [HahnSeries.orderTop_single]
  · rcases eq_or_ne c 0 with rfl | hc
    · rw [HahnSeries.orderTop_single (by norm_num : (1:ℤ) ≠ 0)]
      simp only [HahnSeries.single_eq_zero, HahnSeries.orderTop_zero]
      exact WithTop.coe_lt_top _
    · rw [HahnSeries.orderTop_single (by norm_num : (1:ℤ) ≠ 0),
        HahnSeries.orderTop_single hc]
      exact_mod_cast (by norm_num : (-1 : ℤ) < 0)

/-- A monomial `a · q⁻¹` with `a ≠ 0` is normalized. -/
theorem isMTNormalized_single (a : ℤ) (ha : a ≠ 0) :
    IsMTNormalized (HahnSeries.single (-1) a) := by
  unfold IsMTNormalized
  rw [HahnSeries.orderTop_single ha]

/-- The order at the cusp is additive over finite products of Hahn series. -/
theorem orderTop_prod {ι : Type*} (s : Finset ι) (f : ι → QLaurent) :
    (∏ i ∈ s, f i).orderTop = ∑ i ∈ s, (f i).orderTop := by
  classical
  induction s using Finset.induction with
  | empty => simp
  | insert a s ha ih =>
      rw [Finset.prod_insert ha, Finset.sum_insert ha, HahnSeries.orderTop_mul, ih]

/-- **Pole order of a product of normalized series.**  A product of `#s` McKay--Thompson
normalized series has order exactly `-#s` at the cusp. -/
theorem orderTop_prod_normalized {ι : Type*} (s : Finset ι) (f : ι → QLaurent)
    (hf : ∀ i ∈ s, IsMTNormalized (f i)) :
    (∏ i ∈ s, f i).orderTop = ((-(s.card : ℤ) : ℤ) : WithTop ℤ) := by
  rw [orderTop_prod, Finset.sum_congr rfl hf]
  simp

/-- **The product claim fails: a normalization obstruction.**  A nonempty product of normalized
McKay--Thompson series has a pole at the cusp, hence is not holomorphic there.  Taking
`s.card = 194` — one representative per Monster conjugacy class — the pole order is exactly
`194`, so the product cannot be a holomorphic modular form of any weight. -/
theorem prod_normalized_not_holomorphic {ι : Type*} (s : Finset ι) (f : ι → QLaurent)
    (hs : s.Nonempty) (hf : ∀ i ∈ s, IsMTNormalized (f i)) :
    (∏ i ∈ s, f i).orderTop < ((0 : ℤ) : WithTop ℤ) := by
  rw [orderTop_prod_normalized s f hf]
  have : (0 : ℤ) < (s.card : ℤ) := by exact_mod_cast Finset.card_pos.mpr hs
  exact_mod_cast neg_neg_of_pos this

/-- The concrete Monster-sized instance: a product of `194` normalized series has order `-194`. -/
theorem orderTop_prod_194 (f : Fin 194 → QLaurent) (hf : ∀ i, IsMTNormalized (f i)) :
    (∏ i, f i).orderTop = ((-194 : ℤ) : WithTop ℤ) := by
  rw [orderTop_prod_normalized Finset.univ f (fun i _ => hf i)]
  norm_num

/-- **The pole is the only obstruction.**  Multiplying the product of `#s` normalized series by
`q^{-#s}` (i.e. by the monomial `single (#s) 1`) yields a series of order exactly `0` at the
cusp: the failure of holomorphy is a single integer shift, and after removing it the
renormalized product is a well-defined unit-order series. -/
theorem orderTop_renormalized_prod {ι : Type*} (s : Finset ι) (f : ι → QLaurent)
    (hf : ∀ i ∈ s, IsMTNormalized (f i)) :
    (HahnSeries.single (s.card : ℤ) (1 : ℤ) * ∏ i ∈ s, f i).orderTop = ((0 : ℤ) : WithTop ℤ) := by
  rw [HahnSeries.orderTop_mul, HahnSeries.orderTop_single (by norm_num : (1 : ℤ) ≠ 0),
    orderTop_prod_normalized s f hf]
  norm_cast
  simp

/-- **The product aggregate loses information.**  Two distinct families of normalized series can
have the same product; hence the unlabeled product carries strictly less data than the labeled
family, and no reconstruction map can recover class-indexed information from it alone. -/
theorem prod_aggregate_not_injective :
    ∃ f g : Fin 2 → QLaurent,
      (∀ i, IsMTNormalized (f i)) ∧ (∀ i, IsMTNormalized (g i)) ∧ f ≠ g ∧
        (∏ i, f i) = ∏ i, g i := by
  refine ⟨![HahnSeries.single (-1) 1, HahnSeries.single (-1) 2],
          ![HahnSeries.single (-1) 2, HahnSeries.single (-1) 1], ?_, ?_, ?_, ?_⟩
  · intro i
    fin_cases i
    · exact isMTNormalized_single 1 one_ne_zero
    · exact isMTNormalized_single 2 two_ne_zero
  · intro i
    fin_cases i
    · exact isMTNormalized_single 2 two_ne_zero
    · exact isMTNormalized_single 1 one_ne_zero
  · intro h
    have h0 := congrFun h 0
    simp only [Matrix.cons_val_zero] at h0
    have := congrArg (fun t : QLaurent => t.coeff (-1)) h0
    simp at this
  · simp [Fin.prod_univ_two, mul_comm]

end Laurent

/-! ## Part 7: honest Laurent-series form of the moonshine average -/

section LaurentAverage

open HahnSeries

variable (G : Type*) [Group G] [Fintype G]
variable (X : ℕ → Type*) [∀ n, MulAction G (X n)] [∀ n, Finite (X n)]

/-- The orbit-counting series of the graded action itself (the `k = 1` case). -/
noncomputable def orbitSeries : ℕ → ℕ := fun n => Nat.card (orbitRel.Quotient G (X n))

/-- The `q⁻¹`-normalized trace series attached to `g`, as a genuine Laurent series:
`T_g(q) = q⁻¹ + ∑_{n ≥ 0} |(X n)^g| qⁿ`.  This is the standard McKay--Thompson normalization. -/
noncomputable def traceLaurent (g : G) : QLaurent :=
  HahnSeries.single (-1) 1 +
    HahnSeries.ofPowerSeries ℤ ℤ (PowerSeries.mk fun n => (traceSeries G X g n : ℤ))

/-- The `q⁻¹`-normalized orbit-counting series `O(q) = q⁻¹ + ∑_{n ≥ 0} #(X n / G) qⁿ`. -/
noncomputable def orbitLaurent : QLaurent :=
  HahnSeries.single (-1) 1 +
    HahnSeries.ofPowerSeries ℤ ℤ (PowerSeries.mk fun n => (orbitSeries G X n : ℤ))

/-- A power series, viewed as a Laurent series, has nonnegative order at the cusp. -/
theorem zero_le_orderTop_ofPowerSeries (x : PowerSeries ℤ) :
    ((0 : ℤ) : WithTop ℤ) ≤ (HahnSeries.ofPowerSeries ℤ ℤ x).orderTop := by
  rw [HahnSeries.le_orderTop_iff_forall]
  intro j hj
  have hj' : j < 0 := by exact_mod_cast hj
  rw [HahnSeries.ofPowerSeries_apply]
  refine HahnSeries.embDomain_notin_range ?_
  rintro ⟨n, hn⟩
  have hnj : ((n : ℤ)) = j := hn
  omega

omit [Fintype G] [∀ n, Finite (X n)] in
/-- Every trace series really is McKay--Thompson normalized: its expansion begins with `q⁻¹`. -/
theorem isMTNormalized_traceLaurent (g : G) : IsMTNormalized (traceLaurent G X g) := by
  unfold IsMTNormalized traceLaurent
  rw [HahnSeries.orderTop_add_eq_left, HahnSeries.orderTop_single (by norm_num : (1:ℤ) ≠ 0)]
  rw [HahnSeries.orderTop_single (by norm_num : (1:ℤ) ≠ 0)]
  refine lt_of_lt_of_le ?_ (zero_le_orderTop_ofPowerSeries _)
  exact_mod_cast (by norm_num : (-1 : ℤ) < 0)

omit [Fintype G] [∀ n, Finite (X n)] in
/-- The orbit series is normalized in the same way. -/
theorem isMTNormalized_orbitLaurent : IsMTNormalized (orbitLaurent G X) := by
  unfold IsMTNormalized orbitLaurent
  rw [HahnSeries.orderTop_add_eq_left, HahnSeries.orderTop_single (by norm_num : (1:ℤ) ≠ 0)]
  rw [HahnSeries.orderTop_single (by norm_num : (1:ℤ) ≠ 0)]
  refine lt_of_lt_of_le ?_ (zero_le_orderTop_ofPowerSeries _)
  exact_mod_cast (by norm_num : (-1 : ℤ) < 0)

/-- **Moonshine average at the level of honest Laurent series.**  The sum of the normalized
trace series over the whole group is `|G|` times the normalized orbit series.  This upgrades
the coefficientwise connector of the previous cycle to an identity of `q⁻¹`-normalized Laurent
series — the normalization in which McKay--Thompson series are actually stated. -/
theorem sum_traceLaurent_eq_card_smul_orbitLaurent :
    ∑ g : G, traceLaurent G X g = (Fintype.card G) • orbitLaurent G X := by
  simp only [traceLaurent, orbitLaurent, Finset.sum_add_distrib, smul_add,
    Finset.sum_const, Finset.card_univ, ← map_sum, ← map_nsmul]
  congr 1
  congr 1
  ext n
  simp only [PowerSeries.coeff_mk, map_sum, map_nsmul]
  have hb : ∑ g : G, traceSeries G X g n = orbitSeries G X n * Fintype.card G := by
    have h := sum_card_fixedBy_eq_orbits_mul_card G (X n)
    simpa [traceSeries, orbitSeries, Nat.card_eq_fintype_card] using h
  rw [nsmul_eq_mul, ← Nat.cast_sum, hb]
  push_cast
  ring

omit [Fintype G] [∀ n, Finite (X n)] in
/-- **The Monster-sized product is not holomorphic.**  Any `194` of the normalized trace series
have a product with a pole of order exactly `194` at the cusp; in particular the "product over
all conjugacy classes" cannot be a holomorphic modular form. -/
theorem orderTop_prod_traceLaurent_194 (c : Fin 194 → G) :
    (∏ i, traceLaurent G X (c i)).orderTop = ((-194 : ℤ) : WithTop ℤ) :=
  orderTop_prod_194 _ fun i => isMTNormalized_traceLaurent G X (c i)

end LaurentAverage

/-! ## Part 8: an information-preserving aggregate -/

section Interleaving

open HahnSeries

/-- The order embedding `n ↦ m n + i` of `ℤ`, used to place the `i`-th member of a family into
the arithmetic progression `i mod m`. -/
def stretchEmb (m : ℕ) (hm : 0 < m) (i : ℕ) : ℤ ↪o ℤ :=
  OrderEmbedding.ofStrictMono (fun n => m * n + i) (by
    intro a b hab
    have hm' : (0 : ℤ) < m := by exact_mod_cast hm
    nlinarith)

/-- The **interleaved aggregate** of a family of Laurent series: the `i`-th member is written
into the coefficients indexed by the progression `i mod m`.  This is a single scalar series,
just like the product, but it is labeled. -/
noncomputable def interleave (m : ℕ) (hm : 0 < m) (f : Fin m → QLaurent) : QLaurent :=
  ∑ i : Fin m, HahnSeries.embDomain (stretchEmb m hm i) (f i)

/-- Coefficient extraction from the interleaved aggregate recovers each member exactly. -/
theorem interleave_coeff (m : ℕ) (hm : 0 < m) (f : Fin m → QLaurent) (i : Fin m) (n : ℤ) :
    (interleave m hm f).coeff (m * n + i) = (f i).coeff n := by
  rw [interleave, HahnSeries.coeff_sum, Finset.sum_eq_single i]
  · exact HahnSeries.embDomain_coeff (f := stretchEmb m hm i) (a := n)
  · intro j _ hji
    refine HahnSeries.embDomain_notin_range ?_
    rintro ⟨k, hk⟩
    have hk' : (m : ℤ) * k + j = m * n + i := hk
    have hdvd : (m : ℤ) ∣ ((i : ℤ) - j) := ⟨k - n, by ring_nf; linarith⟩
    have hi : (i : ℤ) < m := by exact_mod_cast i.isLt
    have hj : (j : ℤ) < m := by exact_mod_cast j.isLt
    have hi0 : (0 : ℤ) ≤ (i : ℤ) := Int.natCast_nonneg _
    have hj0 : (0 : ℤ) ≤ (j : ℤ) := Int.natCast_nonneg _
    have habs : |(i : ℤ) - j| < m := by rw [abs_lt]; constructor <;> omega
    have hz : (i : ℤ) - j = 0 := Int.eq_zero_of_abs_lt_dvd hdvd habs
    exact hji (Fin.ext (by omega))
  · intro h; exact absurd (Finset.mem_univ i) h

/-- **The interleaved aggregate is information preserving.**  In contrast with the product
(`prod_aggregate_not_injective`), this scalar aggregate determines the whole labeled family. -/
theorem interleave_injective (m : ℕ) (hm : 0 < m) : Function.Injective (interleave m hm) := by
  intro f g hfg
  funext i
  ext n
  have h1 := interleave_coeff m hm f i n
  have h2 := interleave_coeff m hm g i n
  rw [← h1, ← h2, hfg]

/-- **Dichotomy for scalar aggregates of class-indexed q-series.**  For any number `m ≥ 1` of
classes there is a scalar-valued aggregate that injectively encodes the family, while the
multiplicative aggregate already fails to be injective for `m = 2`.  So the failure of the
"product determines everything" claim is a defect of the product specifically, not of scalar
aggregates in general. -/
theorem exists_injective_aggregate (m : ℕ) (hm : 0 < m) :
    ∃ Φ : (Fin m → QLaurent) → QLaurent, Function.Injective Φ :=
  ⟨interleave m hm, interleave_injective m hm⟩

end Interleaving

/-! ## Part 9: a worked family — the regular action -/

section Regular

variable (G : Type*) [Group G] [Fintype G]

omit [Fintype G] in
/-- In the left regular action, a nonidentity element fixes nothing. -/
theorem card_fixedBy_regular_of_ne_one (g : G) (hg : g ≠ 1) : Nat.card (fixedBy G g) = 0 := by
  have he : IsEmpty (fixedBy G g) := by
    constructor
    rintro ⟨x, hx⟩
    have hgx : g * x = x := hx
    exact hg (by simpa using mul_right_cancel (b := x) (by simpa using hgx))
  simp [Nat.card_of_isEmpty]

/-- **Moments of the regular action.**  The regular representation's trace series has a single
nonzero coefficient, and the moment hierarchy evaluates to `#(G^{k+1}/G) = |G|^k`: the number
of orbits of `G` on `(k+1)`-tuples of group elements.  This is the extreme opposite of the
trivial action in the rigidity theorem, and matches the computed values `1, 4, 16` for the
regular action of a group of order `4`. -/
theorem card_orbits_pi_regular (k : ℕ) :
    Nat.card (orbitRel.Quotient G (Fin (k + 1) → G)) = Nat.card G ^ k := by
  have hmom := sum_fixedPoints_pow_eq_orbits_mul_card G G (k + 1)
  have hs : ∑ g : G, Nat.card (fixedBy G g) ^ (k + 1) = Nat.card G ^ (k + 1) := by
    rw [Finset.sum_eq_single (1 : G)]
    · congr 1
      have h1 : fixedBy G (1 : G) = Set.univ := by ext x; simp
      rw [h1]; simp
    · intro g _ hg; simp [card_fixedBy_regular_of_ne_one G g hg]
    · intro h; exact absurd (Finset.mem_univ (1 : G)) h
  rw [hs] at hmom
  have hcancel : Nat.card G ^ k * Nat.card G
      = Nat.card (orbitRel.Quotient G (Fin (k + 1) → G)) * Nat.card G := by
    rw [← hmom]; ring
  exact (Nat.eq_of_mul_eq_mul_right Nat.card_pos hcancel).symm

end Regular

/-! ## Part 10: freeness is detected by a single moment -/

section Free

variable (G : Type*) [Group G] [Fintype G] (X : Type*) [MulAction G X] [Finite X]

omit [Fintype G] in
/-- A fixed-point-free element in the counting sense really moves every point. -/
theorem smul_ne_self_of_card_fixedBy_eq_zero (g : G) (h : Nat.card (fixedBy X g) = 0) (x : X) :
    g • x ≠ x := by
  rcases Nat.card_eq_zero.mp h with he | hinf
  · intro hgx
    exact he.elim ⟨x, hgx⟩
  · exact absurd (Set.Finite.to_subtype (Set.toFinite _)) (by simpa using hinf.not_finite)

/-- **Freeness from one moment.**  For any single `k`, the action of `G` on `X` is free exactly
when the `(k+1)`-st moment attains the maximal value `|X|^{k+1}`, i.e. when the number of
orbits on `(k+1)`-tuples is `|X|^{k+1}/|G|`.  Together with the rigidity theorem this pins down
both extremes of the moment hierarchy: minimal moments correspond to the trivial action,
maximal moments to free actions. -/
theorem free_iff_orbits_pi (k : ℕ) :
    (∀ g : G, g ≠ 1 → ∀ x : X, g • x ≠ x) ↔
      Nat.card (orbitRel.Quotient G (Fin (k + 1) → X)) * Nat.card G
        = Nat.card X ^ (k + 1) := by
  classical
  have hmom := sum_fixedPoints_pow_eq_orbits_mul_card G X (k + 1)
  have hone : Nat.card (fixedBy X (1 : G)) = Nat.card X := card_fixedBy_one
  constructor
  · intro hfree
    have hzero : ∀ g : G, g ≠ 1 → Nat.card (fixedBy X g) = 0 := by
      intro g hg
      have he : IsEmpty (fixedBy X g) :=
        ⟨fun y => hfree g hg y.1 y.2⟩
      simp [Nat.card_of_isEmpty]
    have hs : ∑ g : G, Nat.card (fixedBy X g) ^ (k + 1) = Nat.card X ^ (k + 1) := by
      rw [Finset.sum_eq_single (1 : G)]
      · rw [hone]
      · intro g _ hg; simp [hzero g hg]
      · intro h; exact absurd (Finset.mem_univ (1 : G)) h
    rw [hs] at hmom
    exact hmom.symm
  · intro hcount g hg x
    rw [hcount] at hmom
    have hsum : ∑ g : G, Nat.card (fixedBy X g) ^ (k + 1)
        = Nat.card (fixedBy X (1 : G)) ^ (k + 1) := by rw [hmom, hone]
    have hsplit : ∑ y ∈ Finset.univ.erase (1 : G), Nat.card (fixedBy X y) ^ (k + 1) = 0 := by
      have h2 := Finset.add_sum_erase Finset.univ
        (fun y => Nat.card (fixedBy X y) ^ (k + 1)) (Finset.mem_univ (1 : G))
      simp only at h2
      omega
    have hgz : Nat.card (fixedBy X g) ^ (k + 1) = 0 :=
      (Finset.sum_eq_zero_iff.mp hsplit) g (Finset.mem_erase.mpr ⟨hg, Finset.mem_univ g⟩)
    exact smul_ne_self_of_card_fixedBy_eq_zero G X g (by simpa using pow_eq_zero_iff'.mp hgz |>.1) x

end Free

/-! ## Part 11: the second moment detects 2-transitivity -/

section TwoTransitivity

variable {G : Type*} [Group G] {X : Type*} [MulAction G X]

/-- Two `2`-tuples lie in the same orbit exactly when a group element carries one to the
other. -/
theorem quot_eq_iff (f g : Fin 2 → X) :
    (Quotient.mk (orbitRel G (Fin 2 → X)) f) = Quotient.mk _ g ↔ ∃ a : G, a • g = f := by
  rw [Quotient.eq, MulAction.orbitRel_apply, MulAction.mem_orbit_iff]

/-- Being diagonal is an orbit invariant of a `2`-tuple. -/
theorem diag_of_quot_eq {f g : Fin 2 → X}
    (h : (Quotient.mk (orbitRel G (Fin 2 → X)) f) = Quotient.mk _ g) (hf : f 0 = f 1) :
    g 0 = g 1 := by
  obtain ⟨a, ha⟩ := (quot_eq_iff f g).mp h
  refine smul_left_cancel a ?_
  have e0 : (a • g) 0 = f 0 := by rw [ha]
  have e1 : (a • g) 1 = f 1 := by rw [ha]
  show (a • g) 0 = (a • g) 1
  rw [e0, e1, hf]

/-- 2-transitivity, phrased for pairs written as `2`-tuples. -/
def TwoTransitive (G X : Type*) [Group G] [MulAction G X] : Prop :=
  ∀ f g : Fin 2 → X, f 0 ≠ f 1 → g 0 ≠ g 1 → ∃ a : G, a • g = f

/-- **The second moment detects 2-transitivity.**  For an action on a set with at least two
points, the number of orbits on pairs equals `2` exactly when the action is transitive and
2-transitive.  Combined with the moment identity this reads
`∑_{g ∈ G} |X^g|² = 2|G|  ↔  G is 2-transitive on X`: a purely character-theoretic criterion
for a strong combinatorial symmetry property. -/
theorem orbitals_eq_two_iff_two_transitive (x y : X) (hxy : x ≠ y) :
    Nat.card (orbitRel.Quotient G (Fin 2 → X)) = 2 ↔
      (TwoTransitive G X ∧ MulAction.IsPretransitive G X) := by
  constructor
  · intro hcard
    obtain ⟨c1, c2, hne, huniv⟩ := Nat.card_eq_two_iff.mp hcard
    have hmem : ∀ e : orbitRel.Quotient G (Fin 2 → X), e = c1 ∨ e = c2 := by
      intro e
      have hme : e ∈ ({c1, c2} : Set _) := by rw [huniv]; trivial
      simpa using hme
    have key : ∀ d u v : orbitRel.Quotient G (Fin 2 → X), d ≠ u → d ≠ v → u = v := by
      intro d u v h1 h2
      rcases hmem d with hd | hd <;> rcases hmem u with hu | hu <;> rcases hmem v with hv | hv <;>
        simp_all
    constructor
    · intro f g hf hg
      have hdu : (Quotient.mk _ (fun _ => f 0) : orbitRel.Quotient G (Fin 2 → X))
          ≠ Quotient.mk _ f := fun h => hf (diag_of_quot_eq h rfl)
      have hdv : (Quotient.mk _ (fun _ => f 0) : orbitRel.Quotient G (Fin 2 → X))
          ≠ Quotient.mk _ g := fun h => hg (diag_of_quot_eq h rfl)
      exact (quot_eq_iff f g).mp (key _ _ _ hdu hdv)
    · refine ⟨fun u v => ?_⟩
      have hdu : (Quotient.mk _ (![x, y]) : orbitRel.Quotient G (Fin 2 → X))
          ≠ Quotient.mk _ (fun _ => u) := by
        intro h
        exact hxy (by simpa using diag_of_quot_eq h.symm rfl)
      have hdv : (Quotient.mk _ (![x, y]) : orbitRel.Quotient G (Fin 2 → X))
          ≠ Quotient.mk _ (fun _ => v) := by
        intro h
        exact hxy (by simpa using diag_of_quot_eq h.symm rfl)
      have heq := key _ _ _ hdu hdv
      obtain ⟨a, ha⟩ := (quot_eq_iff (fun _ => v) (fun _ => u)).mp heq.symm
      exact ⟨a, congrFun ha 0⟩
  · rintro ⟨h2, htr⟩
    refine Nat.card_eq_two_iff.mpr
      ⟨Quotient.mk _ (fun _ => x), Quotient.mk _ (![x, y]), ?_, ?_⟩
    · intro h
      have hd := diag_of_quot_eq h rfl
      simp only [Matrix.cons_val_zero, Matrix.cons_val_one] at hd
      exact hxy hd
    · ext c
      simp only [Set.mem_univ, iff_true, Set.mem_insert_iff, Set.mem_singleton_iff]
      induction c using Quotient.inductionOn with
      | h f =>
        by_cases hf : f 0 = f 1
        · left
          rw [quot_eq_iff]
          obtain ⟨a, ha⟩ := htr.exists_smul_eq x (f 0)
          refine ⟨a, ?_⟩
          funext i
          show a • x = f i
          have hfi : f i = f 0 := by
            fin_cases i
            · rfl
            · exact hf.symm
          rw [hfi]; exact ha
        · right
          rw [quot_eq_iff]
          exact h2 f ![x, y] hf (by simpa using hxy)

/-- Character-theoretic form: the second moment of the fixed-point series equals `2|G|`
exactly for 2-transitive actions. -/
theorem sum_fixedPoints_sq_eq_two_mul_card_iff [Fintype G] [Finite X] (x y : X) (hxy : x ≠ y) :
    (∑ g : G, Nat.card (fixedBy X g) ^ 2) = 2 * Nat.card G ↔
      (TwoTransitive G X ∧ MulAction.IsPretransitive G X) := by
  rw [sum_fixedPoints_pow_eq_orbits_mul_card G X 2, ← orbitals_eq_two_iff_two_transitive x y hxy]
  constructor
  · intro h
    exact Nat.eq_of_mul_eq_mul_right Nat.card_pos h
  · intro h; rw [h]

end TwoTransitivity

end MoonshineMoments