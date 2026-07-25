import Geometry.QuantumSurreal.Basic
import Geometry.QuantumSurreal.StandardPartMeasure

/-!
# Quantum surreal measurement: label invariance and the equal-amplitude obstruction

A surreal number may index a basis ket, but the Born weight of that ket is determined by its
amplitude rather than by the arithmetic magnitude of its label.  This distinction is decisive for
infinitesimal surreal labels: attaching an infinitesimal label to an appreciable amplitude does not
make the corresponding outcome infinitesimally probable.

This chapter establishes a sharp two-branch measurement law over hyperreal amplitudes.  It proves
that two distinct surreal-labelled branches with the same nonzero amplitude each have exact Born
weight `1/2` and observed probability `1/2`, irrespective of whether either label is infinitesimal.
It then contrasts this obstruction with the genuine infinitesimal-amplitude collapse developed in
`Geometry.QuantumSurreal.Basic` and with the discrete standard-part collapse developed in
`Geometry.QuantumSurreal.StandardPartMeasure`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): six falsifiable conjectures were ranked by expected impact:
(1) a spectral theorem for finite-rank self-adjoint operators over a standard-part-compatible
non-Archimedean scalar field; (2) extension of that decomposition to an appropriate complete
quantum-surreal Hilbert geometry; (3) functorial preservation of finite Born normalization by
standard part; (4) equivalence between hyperreal and lexicographic infinitesimal collapse on finite
sample spaces; (5) invariance of measurement probabilities under permutations of surreal labels;
and (6) suppression of an appreciably weighted branch merely because its surreal label is
infinitesimal.  The final conjecture is the concrete test addressed here.

Experiment (Experimenter): finite two-branch calculations give squared norm `2a²` for the state
`a|s⟩ + a|t⟩`.  For every nonzero `a`, division gives exact weights `a²/(2a²)=1/2` on both branches.
The calculation is insensitive to the order, birthday, or infinitesimal status of `s` and `t`.

Analysis (Analyst): conjecture (6) fails because labels and amplitudes play categorically different
roles.  Labels choose orthogonal coordinates; amplitudes determine mass.  Conjectures (3)--(5)
survive in the finite setting: normalization is retained in the epsilon test, two independent
infinitesimal models share the same collapse signature, and swapping the two labels preserves the
half weights.  Conjectures (1) and (2) remain true-but-hard candidates requiring a developed
non-Archimedean inner-product and completeness theory.  Standard part can erase an infinitesimal
weight, but it cannot turn the appreciable hyperreal `1/2` into zero.

Critique (Critic): distinctness of the labels and nonzeroness of the common amplitude are essential.
If labels coincide, the amplitudes add before squaring; if the amplitude is zero, normalization is
undefined.  The result uses the existing norm computation and field cancellation rather than a
finite decision procedure or definitional reduction.

Synthesis (Principal Investigator): infinitesimal unobservability is an amplitude phenomenon, not a
label phenomenon.  The verified boundary theorem separates a sound non-Archimedean measurement
principle from an invalid label-dependent rule.
-- !-- Lab Notes -- !--
-/

open Hyperreal Finsupp

namespace QuantumSurreal

/-- A two-branch state with a common hyperreal amplitude. -/
noncomputable def equalAmplitudePair (s t : Surreal.{0}) (a : ℝ*) : QSurreal :=
  single s a + single t a

/-- Two distinct equally weighted branches have squared norm `2a²`. -/
theorem normSq_equalAmplitudePair (s t : Surreal.{0}) (a : ℝ*) (hst : s ≠ t) :
    normSq (equalAmplitudePair s t a) = 2 * a ^ 2 := by
  rw [equalAmplitudePair, normSq_pair s t a a hst]
  ring

/-
The exact Born weight of the first branch of a nonzero equal-amplitude pair is `1/2`.
-/
theorem bornProb_equalAmplitudePair_left (s t : Surreal.{0}) (a : ℝ*)
    (hst : s ≠ t) (ha : a ≠ 0) :
    bornProb (equalAmplitudePair s t a) s = (2 : ℝ*)⁻¹ := by
  convert congr_arg ( fun x : ℝ* => ( equalAmplitudePair s t a ) s ^ 2 / x ) ( normSq_equalAmplitudePair s t a hst ) using 1;
  simp +decide [ equalAmplitudePair, hst ];
  grind +qlia

/-
The exact Born weight of the second branch of a nonzero equal-amplitude pair is `1/2`.
-/
theorem bornProb_equalAmplitudePair_right (s t : Surreal.{0}) (a : ℝ*)
    (hst : s ≠ t) (ha : a ≠ 0) :
    bornProb (equalAmplitudePair s t a) t = (2 : ℝ*)⁻¹ := by
  convert bornProb_equalAmplitudePair_left t s a hst.symm ha using 1;
  unfold equalAmplitudePair; simp +decide [ add_comm ] ;

/-
Standard-part observation preserves the half weight of the first branch.
-/
theorem observedProb_equalAmplitudePair_left (s t : Surreal.{0}) (a : ℝ*)
    (hst : s ≠ t) (ha : a ≠ 0) :
    observedProb (equalAmplitudePair s t a) s = (1 : ℝ) / 2 := by
  unfold observedProb bornProb;
  rw [ normSq_equalAmplitudePair s t a hst ];
  simp_all +decide [ equalAmplitudePair ];
  rw [ show a ^ 2 / ( 2 * a ^ 2 ) = 2⁻¹ by rw [ div_eq_iff ( by aesop ) ] ; ring ];
  convert Hyperreal.st_id_real ( 2⁻¹ ) using 1

/-
**Equal-amplitude obstruction.**  Both distinct surreal-labelled outcomes have observed
probability `1/2`.  In particular, making one label infinitesimal cannot make its branch
unobservable while its amplitude remains equal to the other branch's amplitude.
-/
theorem equal_amplitude_obstruction (s t : Surreal.{0}) (a : ℝ*)
    (hst : s ≠ t) (ha : a ≠ 0) :
    observedProb (equalAmplitudePair s t a) s = (1 : ℝ) / 2 ∧
      observedProb (equalAmplitudePair s t a) t = (1 : ℝ) / 2 := by
  refine' ⟨ QuantumSurreal.observedProb_equalAmplitudePair_left s t a hst ha, _ ⟩;
  convert observedProb_equalAmplitudePair_left t s a hst.symm ha using 1;
  unfold equalAmplitudePair; simp +decide [ add_comm ] ;

/-- The genuine infinitesimal-amplitude test remains normalized after observation: its two
observed probabilities sum to one. -/
theorem epsilon_test_observed_normalized :
    observedProb psiTest 0 + observedProb psiTest 1 = 1 := by
  rcases epsilon_test with ⟨h0, h1⟩
  rw [h0, h1, add_zero]

/-- The discrete lexicographic model has the same standard-part signature: total mass one and each
visible infinitesimal atom mass zero. -/
theorem discrete_continuous_standard_part_bridge (n : ℕ) (i : Fin n) :
    InfinitesimalProbability.stdPart (InfinitesimalProbability.prob n Finset.univ) = 1 ∧
      InfinitesimalProbability.stdPart (InfinitesimalProbability.prob n {some i}) = 0 := by
  constructor
  · exact InfinitesimalProbability.stdPart_prob_univ n
  · exact InfinitesimalProbability.stdPart_visible_zero n i

end QuantumSurreal