# Future Directions: Proof Phase Transitions via Spin-Glass Complexity

## 1. Quantitative Freezing Threshold for Random k-CSPs

Formalize the statement that for random k-SAT at clause-to-variable ratio α,
there exists a critical threshold α_f such that for α < α_f the backbone fraction
is o(1) and for α > α_f the backbone fraction is Ω(1). The key insight is that our
backbone monotonicity theorem (`backbone_monotone`) and tower monotonicity
(`CSPTower.backbone_mono`) provide the formal scaffolding — what's needed is a
probabilistic argument over random CSP ensembles showing the backbone fraction
concentrates and has a discontinuous jump. Why now? Our framework already handles
the deterministic backbone structure; the next step is coupling it with Mathlib's
measure-theoretic probability to formalize the Erdős–Rényi style threshold.

## 2. Overlap Distribution and Replica Symmetry Breaking

Define the overlap distribution P(q) for a CSP — the distribution of normalized
Hamming overlap |agreeSet(σ,τ)|/n when σ, τ are drawn uniformly from the solution
set — and prove that replica symmetry breaking (RSB) corresponds to P(q) being
non-trivially supported on multiple values. The key insight is that
`backbone_subset_agreeSet` already shows the overlap is bounded below by the
backbone fraction β; the RSB phase is characterized by P(q) having support both
near β (inter-cluster overlap) and near 1 (intra-cluster overlap). Why now?
Mathlib's `MeasureTheory.ProbabilityMeasure` is mature enough to define P(q)
rigorously, and our backbone framework provides the lower bound anchor.

## 3. Cavity Method and Belief Propagation Fixed Points

Formalize the cavity method for CSPs: define the Bethe free energy as a functional
on message distributions, prove that its critical points correspond to belief
propagation fixed points, and show that the number of such fixed points undergoes a
phase transition from one (replica-symmetric) to exponentially many (RSB). The key
insight is that belief propagation on factor graphs is a fixed-point iteration on a
finite-dimensional space, so Brouwer's theorem guarantees existence — the
interesting question is uniqueness vs. multiplicity. Why now? Mathlib has Brouwer's
fixed-point theorem and extensive topology infrastructure; the gap is formalizing
factor graphs and the Bethe functional.

## 4. Backbone-Guided Proof Search Complexity Lower Bounds

Prove that for CSPs in the frozen phase (backbone fraction > 0), any resolution
proof of unsatisfiability (when the CSP transitions from satisfiable to
unsatisfiable near the critical threshold) requires exponential length. The key
insight is that `non_backbone_disagreeing_pair` shows that non-backbone variables
admit "free" flips, while backbone variables create long-range correlations that
force any resolution refutation to "discover" each backbone variable — giving a
lower bound proportional to 2^|backbone|. Why now? Our `solution_count_backbone_bound`
theorem already connects backbone size to solution count; the next step is proving
the dual statement about proof complexity.

## 5. Universality of the Freezing Transition Across Encodings

Formalize the conjecture that the freezing transition is encoding-independent:
for a fixed mathematical theorem-search problem, define multiple CSP encodings
(SAT, SMT, term rewriting) and prove that the backbone fraction as a function of
constraint density has the same critical exponent across encodings. The key insight
is that different encodings of the same problem are related by polynomial-time
reductions that map backbone variables to backbone variables (up to a bounded
expansion factor), so the critical behavior is preserved up to rescaling. Why now?
Our abstract `CSP` framework is already encoding-agnostic — formalizing the
reduction maps between specific encodings would establish universality at the
structural level.
