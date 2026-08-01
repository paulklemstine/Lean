import Mathlib

/-!
# Certified robustness and a finite cellular sheaf counterexample

This file isolates a precise contrarian test of the proposed principle.  The
cohomology model is the degree-one cellular cohomology of the constant real
sheaf on the graph consisting of two weight charts and their overlap.  Its
first cohomology vanishes, but this topological fact alone does not constrain
a classifier's decision margin.  A threshold classifier supplies a certified
counterexample.  We also prove a corrected analytic theorem: a positive margin
together with a local Lipschitz estimate gives an explicit `L∞` certificate.
-/

namespace CertifiedAdversarialRobustness

/-- The decision associated to a real-valued score, with zero assigned to the
negative class. -/
noncomputable def decision {X : Type*} (score : X → ℝ) (x : X) : Bool := decide (0 < score x)

/-- A strict-radius robustness certificate in an arbitrary distance model. -/
def CertifiedAt {X : Type*} (dist : X → X → ℝ) (score : X → ℝ)
    (x : X) (radius : ℝ) : Prop :=
  ∀ y, dist x y < radius → decision score y = decision score x

/-- A concrete `L∞` distance on finite-dimensional real input spaces. -/
noncomputable def linfDist {n : ℕ} (x y : Fin n → ℝ) : ℝ :=
  ‖x - y‖

/-- The local vulnerability stalk at `(x,r)`: its elements are adversarial
examples lying strictly inside the `L∞` ball. -/
def VulnerabilityStalk {n : ℕ} (score : (Fin n → ℝ) → ℝ)
    (x : Fin n → ℝ) (radius : ℝ) :=
  {y : Fin n → ℝ // linfDist x y < radius ∧ decision score y ≠ decision score x}

/-- The stalk is empty exactly when the corresponding ball is certified. -/
theorem vulnerabilityStalk_empty_iff_certified {n : ℕ}
    (score : (Fin n → ℝ) → ℝ) (x : Fin n → ℝ) (radius : ℝ) :
    IsEmpty (VulnerabilityStalk score x radius) ↔
      CertifiedAt linfDist score x radius := by
  constructor
  · intro h y hy
    by_contra hne
    exact h.false ⟨y, hy, hne⟩
  · intro h
    refine ⟨?_⟩
    intro z
    exact z.property.2 (h z.1 z.property.1)

/-! ## A two-chart cellular sheaf

A section over the two vertices is a pair `(a,b)`.  Its Čech/cellular
coboundary on their oriented overlap is `b-a`.  Degree-one cohomology vanishes
when every overlap cochain is such a coboundary.
-/

/-- Degree-zero coboundary for the constant sheaf on one edge. -/
def edgeCoboundary (s : ℝ × ℝ) : ℝ := s.2 - s.1

/-- Vanishing first cohomology of the two-chart constant cellular sheaf. -/
def EdgeH1Vanishing : Prop := Function.Surjective edgeCoboundary

/-- The explicit constant sheaf on two charts has vanishing first cohomology. -/
theorem edge_constant_sheaf_H1_vanishes : EdgeH1Vanishing := by
  intro c
  exact ⟨(0, c), by simp [edgeCoboundary]⟩

/-- On the real line, the absolute-value metric is the one-dimensional
`L∞` metric. -/
def realLinfDist (x y : ℝ) : ℝ := |x - y|

/-- The threshold score has an adversarial example in every positive-radius
ball around its decision boundary. -/
theorem threshold_has_no_positive_certificate :
    ¬ ∃ radius : ℝ, 0 < radius ∧
      CertifiedAt realLinfDist id 0 radius := by
  rintro ⟨r, hr, hcert⟩
  have hinside : realLinfDist 0 (r / 2) < r := by
    rw [realLinfDist, zero_sub, abs_neg, abs_of_pos (half_pos hr)]
    linarith
  have heq := hcert (r / 2) hinside
  simp [decision, hr] at heq

/-- **Disproof of the unqualified cohomological conjecture.** Even though the
weight-chart sheaf has vanishing `H¹`, a classifier can have zero certified
radius at a decision-boundary input. -/
theorem vanishing_H1_does_not_imply_certified_radius :
    EdgeH1Vanishing ∧
      ¬ ∃ radius : ℝ, 0 < radius ∧
        CertifiedAt realLinfDist id 0 radius := by
  exact ⟨edge_constant_sheaf_H1_vanishes,
    threshold_has_no_positive_certificate⟩

/-- A direct logical refutation of the universal version of the proposed
implication: no theorem can derive robustness of every score merely from this
vanishing cohomology premise. -/
theorem universal_cohomology_robustness_conjecture_is_false :
    ¬ (EdgeH1Vanishing →
      ∀ score : ℝ → ℝ, ∃ radius : ℝ, 0 < radius ∧
        CertifiedAt realLinfDist score 0 radius) := by
  intro h
  obtain ⟨r, hr, hcert⟩ := h edge_constant_sheaf_H1_vanishes id
  exact threshold_has_no_positive_certificate ⟨r, hr, hcert⟩

/-! ## Corrected positive statement

Topology can organize local data, but a numerical certificate requires an
analytic bridge.  The next result gives that bridge without assuming any
cohomology: positive score margin and a local Lipschitz bound imply robustness.
-/

/-- A positive margin and a strict `L∞` Lipschitz budget certify the positive
class throughout the prescribed ball. -/
theorem margin_lipschitz_implies_linf_certificate {n : ℕ}
    (score : (Fin n → ℝ) → ℝ) (x : Fin n → ℝ)
    (margin L radius : ℝ)
    (hmargin : margin ≤ score x) (hmargin_pos : 0 < margin)
    (hbudget : L * radius < margin)
    (hlip : ∀ y, linfDist x y < radius →
      |score y - score x| ≤ L * linfDist x y)
    (hL : 0 ≤ L) :
    CertifiedAt linfDist score x radius := by
  intro y hy
  have hdist : L * linfDist x y < margin := by
    calc
      L * linfDist x y ≤ L * radius :=
        mul_le_mul_of_nonneg_left (le_of_lt hy) hL
      _ < margin := hbudget
  have habs := hlip y hy
  have hlower : score x - score y ≤ L * linfDist x y := by
    calc
      score x - score y ≤ |score y - score x| := by
        rw [abs_sub_comm]
        exact le_abs_self (score x - score y)
      _ ≤ L * linfDist x y := habs
  have hypos : 0 < score y := by linarith
  have hxpos : 0 < score x := lt_of_lt_of_le hmargin_pos hmargin
  simp [decision, hypos, hxpos]

end CertifiedAdversarialRobustness