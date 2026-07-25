import Mathlib
import Catalog.Applications.Computation.MixedRadixBijection

/-!
# Aardal–Lenstra denumerants: lattice compression identities

Let `aᵢ = pᵢ M + rᵢ N`.  The large one-dimensional knapsack weight then factors
through the two small-coordinate statistics `Σ pᵢxᵢ` and `Σ rᵢxᵢ`.  This file
establishes the algebraic and lattice-theoretic core of that compression.

The central result is a constructive kernel theorem.  Given a Bézout certificate
`uM + vN = 1`, any two vectors with equal weighted sum have aggregate differences
of the form `(Nk, -Mk)`.  Thus every fiber lies on an affine rank-one lattice.
The determinant identities show simultaneously why
`Δ = max |rᵢpⱼ-rⱼpᵢ|` controls pairwise elimination while the large parameters
factor out exactly.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer), ranked by expected impact:
(1) the full constant-term algorithm admits a bit-complexity proof depending on
`n` and the maximal minor `Δ`, but not on `M`, `N`, or the target;
(2) every fiber of the structured knapsack map is exactly an affine primitive
rank-one lattice after rank-two aggregation;
(3) a bounded fundamental strip yields a canonical, output-sensitive
enumeration of every fiber;
(4) the pairwise determinant bound `Δ` controls the number of chambers of the
associated vector partition function;
(5) the constant-term decomposition is functorial under unimodular changes of
the two aggregate coordinates;
(6) short two-coordinate presentations can be recovered with approximation
bounds strong enough to preserve denumerant complexity.
The present cycle tests (2), the uniqueness core of (3), and the determinant
algebra underlying (4) and (5).

Experiment (Experimenter): Small integer vectors were enumerated for `(M,N) =
(5,7)` and several signed coefficient pairs.  Every equal-weight collision had
aggregate difference divisible by `(7,-5)`.  Symbolic expansion confirmed both
minor identities.  The bounded-box cardinality was compared with mixed-radix
encoding to test that the finite search space has the expected product size.

Analysis (Analyst): The Bézout equation gives a constructive proof requiring no
unique-factorization machinery.  The kernel parameter is unique when either
large parameter is nonzero.  Consequently, a strip narrower than `|N|` in the
first aggregate coordinate meets each weighted-sum fiber at most once.

Critique (Critic): Signed `pᵢ,rᵢ` are allowed, so positivity is not silently
assumed.  The kernel statement explicitly requires a Bézout certificate.  Strip
injectivity requires `N ≠ 0`; without it the parameter cannot be recovered from
the first coordinate.  The results concern the structural reduction underlying
evaluation, not the paper's asymptotic running-time bound.

Synthesis (Principal Investigator): Factorization, primitive-kernel
parametrization, determinant elimination, strip uniqueness, and finite-box
counting form a reusable foundation for a constant-term implementation of the
denumerant algorithm.
-/

namespace AardalLenstra

open scoped BigOperators

/-- The structured Aardal–Lenstra coefficient `aᵢ = pᵢM + rᵢN`. -/
def weight {n : ℕ} (p r : Fin n → ℤ) (M N : ℤ) (i : Fin n) : ℤ :=
  p i * M + r i * N

/-- The aggregate coordinate associated with a coefficient vector. -/
def aggregate {n : ℕ} (c : Fin n → ℤ) (x : Fin n → ℤ) : ℤ :=
  ∑ i, c i * x i

/-- The original one-dimensional knapsack functional. -/
def weightedSum {n : ℕ} (p r : Fin n → ℤ) (M N : ℤ) (x : Fin n → ℤ) : ℤ :=
  ∑ i, weight p r M N i * x i

/-
The structured knapsack map factors through its two aggregate coordinates.
-/
theorem weightedSum_decompose {n : ℕ} (p r : Fin n → ℤ) (M N : ℤ)
    (x : Fin n → ℤ) :
    weightedSum p r M N x = M * aggregate p x + N * aggregate r x := by
  unfold weightedSum aggregate
  simp +decide [mul_comm, Finset.mul_sum _ _ _]
  simpa only [ ← Finset.sum_add_distrib ] using Finset.sum_congr rfl fun i _ => by unfold weight; ring;

/-
Constructive primitive-kernel theorem for the coprime two-coordinate map.
-/
theorem bezout_kernel_parametrization {M N P R P' R' u v : ℤ}
    (hbez : u * M + v * N = 1)
    (heq : M * P + N * R = M * P' + N * R') :
    ∃ k : ℤ, P - P' = N * k ∧ R - R' = -M * k := by
  use v * ( P - P' ) - u * ( R - R' );
  grind

/-
Equal structured knapsack values differ by the primitive aggregate direction.
-/
theorem collision_lies_on_kernel {n : ℕ} (p r : Fin n → ℤ) (M N u v : ℤ)
    (hbez : u * M + v * N = 1) (x y : Fin n → ℤ)
    (hxy : weightedSum p r M N x = weightedSum p r M N y) :
    ∃ k : ℤ,
      aggregate p x - aggregate p y = N * k ∧
      aggregate r x - aggregate r y = -M * k := by
  have := @bezout_kernel_parametrization M N;
  exact this hbez ( by linarith [ weightedSum_decompose p r M N x, weightedSum_decompose p r M N y ] )

/-
Eliminating the `p` coordinate extracts `N` times the small determinant.
-/
theorem weight_mul_p_sub_weight_mul_p {n : ℕ} (p r : Fin n → ℤ) (M N : ℤ)
    (i j : Fin n) :
    weight p r M N i * p j - weight p r M N j * p i =
      N * (r i * p j - r j * p i) := by
  unfold weight; ring;

/-
Eliminating the `r` coordinate extracts `M` times the same determinant.
-/
theorem weight_mul_r_sub_weight_mul_r {n : ℕ} (p r : Fin n → ℤ) (M N : ℤ)
    (i j : Fin n) :
    weight p r M N i * r j - weight p r M N j * r i =
      -M * (r i * p j - r j * p i) := by
  unfold weight; ring;

/-
A strip narrower than `|N|` contains at most one aggregate point in a fiber.
-/
theorem narrow_strip_collision_rigid {M N P R P' R' u v : ℤ}
    (hbez : u * M + v * N = 1)
    (hN : N ≠ 0)
    (heq : M * P + N * R = M * P' + N * R')
    (hnarrow : |P - P'| < |N|) : P = P' ∧ R = R' := by
  obtain ⟨ k, hk ⟩ := bezout_kernel_parametrization hbez heq;
  simp_all +decide [ sub_eq_iff_eq_add ]

/-
Complete description of every fiber as an affine copy of the primitive kernel lattice.
-/
theorem same_value_iff_kernel_translate {M N P R P' R' u v : ℤ}
    (hbez : u * M + v * N = 1) :
    M * P + N * R = M * P' + N * R' ↔
      ∃ k : ℤ, P - P' = N * k ∧ R - R' = -M * k := by
  grind +suggestions

/-- A concrete collision used in the small-case exploration: the aggregate
points `(11,-4)` and `(4,1)` differ by `(7,-5)`. -/
example : (5 : ℤ) * 11 + 7 * (-4) = 5 * 4 + 7 * 1 := by norm_num

/-- A uniform finite search box has the expected mixed-radix product cardinality.
This specializes the catalog's general mixed-radix bijection. -/
theorem boundedBox_card (b n : ℕ) :
    Fintype.card (Fin n → Fin b) = b ^ n := by
  rw [← MixedRadix.baseN_radixProd]
  exact MixedRadix.card_valid_tuples (fun _ => b) n

end AardalLenstra