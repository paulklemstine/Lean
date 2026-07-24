import Applications.PoincareData.MetricFiltration
import Algebra.VietorisRipsCliqueExtremalDeepening

/-!
# Stability and exact boundaries for finite Rips thresholds

A finite point cloud is represented by an indexed map into a metric space.  This
chapter isolates two facts needed before a homological sphere-recognition principle
can be credible.  First, uniform perturbation by `δ` shifts every Rips scale by at
most `2δ`.  Second, the scale at which the clique complex becomes the full simplex
is exactly the diameter threshold, not a sphere-recognition threshold.  Samples on a
sphere therefore have a universal complete-simplex bound, while this bound alone
contains no homological information.
-/

noncomputable section

open Classical Finset
open VRCliqueExtremalDeepening

namespace PoincareData

variable {ι M : Type*} [Fintype ι] [DecidableEq ι] [PseudoMetricSpace M]

/-- The Rips graph of an indexed point cloud, allowing repeated observations. -/
def cloudRipsGraph (X : ι → M) (ε : ℝ) : SimpleGraph ι where
  Adj i j := i ≠ j ∧ dist (X i) (X j) ≤ ε
  symm := by rintro i j ⟨hij, hdist⟩; exact ⟨hij.symm, by simpa [dist_comm] using hdist⟩
  loopless := ⟨fun i h => h.1 rfl⟩

/-- The finite flag (clique) complex associated with the cloud Rips graph. -/
def cloudRipsComplex (X : ι → M) (ε : ℝ) : Finset (Finset ι) :=
  cliqueFamily (cloudRipsGraph X ε)

/-
Rips graphs form a filtration in the scale parameter.
-/
omit [Fintype ι] [DecidableEq ι] in
theorem cloudRipsGraph_mono (X : ι → M) {ε η : ℝ} (hεη : ε ≤ η) :
    cloudRipsGraph X ε ≤ cloudRipsGraph X η := by
      intro i j hij;
      exact ⟨ hij.1, le_trans hij.2 hεη ⟩

/-
The corresponding flag complexes form a filtration.
-/
theorem cloudRipsComplex_mono (X : ι → M) {ε η : ℝ} (hεη : ε ≤ η) :
    cloudRipsComplex X ε ⊆ cloudRipsComplex X η := by
      exact VRCliqueExtremalDeepening.cliqueFamily_mono ( cloudRipsGraph_mono X hεη )

/-
Pointwise `δ`-perturbations shift the Rips graph by at most `2δ`.
-/
omit [Fintype ι] [DecidableEq ι] in
theorem cloudRipsGraph_perturbation_le
    (X Y : ι → M) {ε δ : ℝ} (hpert : ∀ i, dist (X i) (Y i) ≤ δ) :
    cloudRipsGraph X ε ≤ cloudRipsGraph Y (ε + 2 * δ) := by
      have h_triangle_ineq : ∀ i j : ι, dist (X i) (X j) ≤ ε → dist (Y i) (Y j) ≤ ε + 2 * δ := by
        intro i j hij;
        linarith [ hpert i, hpert j, dist_triangle4_left ( X i ) ( X j ) ( Y i ) ( Y j ), dist_triangle4_right ( X i ) ( X j ) ( Y i ) ( Y j ) ];
      exact fun i j hij => ⟨ hij.1, h_triangle_ineq i j hij.2 ⟩

/-
Uniform perturbation consequently gives a one-sided inclusion of flag complexes.
-/
theorem cloudRipsComplex_perturbation_subset
    (X Y : ι → M) {ε δ : ℝ} (hpert : ∀ i, dist (X i) (Y i) ≤ δ) :
    cloudRipsComplex X ε ⊆ cloudRipsComplex Y (ε + 2 * δ) := by
      convert cliqueFamily_mono ( cloudRipsGraph_perturbation_le X Y hpert ) using 1

/-
Matched pointwise perturbations give the two inclusions of a `2δ`-shifted
Rips interleaving.
-/
theorem cloudRipsComplex_perturbation_interleaving
    (X Y : ι → M) {ε δ : ℝ} (hpert : ∀ i, dist (X i) (Y i) ≤ δ) :
    cloudRipsComplex X ε ⊆ cloudRipsComplex Y (ε + 2 * δ) ∧
    cloudRipsComplex Y ε ⊆ cloudRipsComplex X (ε + 2 * δ) := by
      refine' ⟨ cloudRipsComplex_perturbation_subset X Y hpert, _ ⟩;
      convert VRCliqueExtremalDeepening.cliqueFamily_mono ( cloudRipsGraph_perturbation_le Y X _ ) using 1;
      simpa only [ dist_comm ] using hpert

/-
The simplex count is stable in the interleaving sense under pointwise noise.
-/
theorem card_cloudRipsComplex_perturbation_le
    (X Y : ι → M) {ε δ : ℝ} (hpert : ∀ i, dist (X i) (Y i) ≤ δ) :
    (cloudRipsComplex X ε).card ≤
      (cloudRipsComplex Y (ε + 2 * δ)).card := by
        convert Finset.card_le_card ( cloudRipsComplex_perturbation_subset X Y hpert ) using 1

/-
Maximal simplex count is an exact all-pairs distance condition.
-/
theorem card_cloudRipsComplex_eq_two_pow_iff
    (X : ι → M) {ε : ℝ} (hε : 0 ≤ ε) :
    (cloudRipsComplex X ε).card = 2 ^ Fintype.card ι ↔
      ∀ i j, dist (X i) (X j) ≤ ε := by
        convert VRCliqueExtremalDeepening.card_cliqueFamily_eq_two_pow_iff ( cloudRipsGraph X ε ) using 1;
        -- If the cloudRipsGraph X ε is the complete graph, then for any i ≠ j, the distance between X i and X j is ≤ ε.
        apply Iff.intro;
        · intro h; ext i j; by_cases hij : i = j <;> simp +decide [ *, cloudRipsGraph ] ;
        · intro h i j; by_cases hij : i = j <;> simp_all +decide [ cloudRipsGraph ] ;
          replace h := congr_arg ( fun f => f.Adj i j ) h ; aesop

/-
Any pair beyond the scale forces a strict deficit from the full simplex.
-/
theorem card_cloudRipsComplex_lt_of_far_pair
    (X : ι → M) {ε : ℝ} (hε : 0 ≤ ε)
    {i j : ι} (hfar : ε < dist (X i) (X j)) :
    (cloudRipsComplex X ε).card < 2 ^ Fintype.card ι := by
      convert card_cliqueFamily_lt_of_ne_top ( cloudRipsGraph X ε ) _ using 1;
      intro h; have := congr_arg ( fun G => G.Adj i j ) h; simp_all +decide [ cloudRipsGraph ] ;
      replace h := congr_arg ( fun f => f.Adj i j ) h ; simp_all +decide;
      exact not_lt_of_ge ( h ( by rintro rfl; exact absurd hfar ( by norm_num; linarith ) ) ) hfar

/-
A spherical point cloud reaches the full-simplex regime by twice its radius.
-/
theorem sphere_cloud_full_simplex
    [NormedAddCommGroup M] [NormedSpace ℝ M]
    (X : ι → M) (c : M) {r : ℝ} (hr : 0 ≤ r)
    (hsphere : ∀ i, dist (X i) c = r) :
    (cloudRipsComplex X (2 * r)).card = 2 ^ Fintype.card ι := by
      convert card_cloudRipsComplex_eq_two_pow_iff X _;
      any_goals exact mul_nonneg zero_le_two hr;
      constructor <;> intro h <;> simp_all +decide [ two_mul ];
      · grind +suggestions;
      · exact fun i j => by linarith [ dist_triangle_right ( X i ) ( X j ) c, hsphere i, hsphere j ] ;

/-
An approximate spherical sample reaches the full-simplex regime by
`2(r+δ)`.  This is a geometric robustness statement, independent of homology.
-/
theorem approximate_sphere_cloud_full_simplex
    [NormedAddCommGroup M] [NormedSpace ℝ M]
    (X : ι → M) (c : M) {r δ : ℝ} (hr : 0 ≤ r) (hδ : 0 ≤ δ)
    (hsphere : ∀ i, |dist (X i) c - r| ≤ δ) :
    (cloudRipsComplex X (2 * (r + δ))).card = 2 ^ Fintype.card ι := by
      rw [ card_cloudRipsComplex_eq_two_pow_iff ];
      · intro i j; linarith [ abs_le.mp ( hsphere i ), abs_le.mp ( hsphere j ), dist_triangle_right ( X i ) ( X j ) c, dist_triangle_left ( X i ) ( X j ) c ] ;
      · positivity

/-
A concrete two-point cloud becomes a full simplex at scale `2`.
-/
theorem example_two_point_full :
    (cloudRipsComplex (fun i : Fin 2 => if i = 0 then (0 : ℝ) else 2) 2).card = 4 := by
      convert card_cloudRipsComplex_eq_two_pow_iff ( fun i => if i = 0 then 0 else 2 : Fin 2 → ℝ ) _;
      case convert_1 => exact 2;
      · norm_num [ Fin.forall_fin_two, dist_eq_norm ];
      · norm_num

/-
The same cloud is not yet a full simplex at scale `1`.
-/
theorem example_two_point_not_full :
    (cloudRipsComplex (fun i : Fin 2 => if i = 0 then (0 : ℝ) else 2) 1).card < 4 := by
      convert card_cloudRipsComplex_lt_of_far_pair _ zero_le_one _;
      exacts [ 0, 1, by norm_num [ dist_eq_norm ] ]

#check cloudRipsComplex_perturbation_interleaving
#check card_cloudRipsComplex_eq_two_pow_iff

/-
-- !-- Lab Notes -- !--

Hypothesis. Seven falsifiable targets were ranked by impact: (1) homological sphere
recognition under quantitative sampling hypotheses; (2) an `n^{-1/d}` random covering
threshold with explicit tails; (3) persistence-module interleaving under Hausdorff
noise; (4) deterministic `2δ` Rips interleaving for matched samples; (5) exact
identification of the full-simplex threshold with diameter; (6) a twice-radius upper
bound for spherical samples; and (7) strict loss of simplices below any witnessed
pair distance. The first three are grand-challenge bridges among topology, probability,
and metric geometry.

Experiment. Targets (4)--(7) survive in deterministic form.  The two-point examples
calculate the sharp transition at scales `1` and `2`; they also expose that simplex
maximality is not sphere recognition.  No external sequence signal was supplied, so
OEIS or LMFDB data did not influence target selection.

Analysis. The common structure is an order-theoretic filtration: triangle inequalities
produce a scale translation, graph inclusion produces clique-complex inclusion, and
finite-cardinality monotonicity produces numerical stability.  The broader
generalization is to correspondences rather than indexwise matchings and then to
persistence modules.

Critique. Homology equal to that of a sphere does not by itself determine homeomorphism
or geometric nearness, and the original ambient dimension and sphere dimension were
conflated.  Boundary cases include repeated observations, empty clouds, negative
scales, and arbitrary nonuniform samples.  The results here make no unjustified
homological inference; nonnegative scale is explicit where diagonal distances matter.

Synthesis. The verified core is a metric--combinatorial bridge: matched perturbations
give a `2δ` interleaving of Rips flag complexes, while the complete-complex transition
is characterized exactly by the cloud diameter condition.  Any future Poincare-type
data theorem must add sampling density, manifold regularity, and genuine homological
or homotopical hypotheses beyond this core.
-- !--
-/

end PoincareData