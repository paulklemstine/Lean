# Future Directions

## Synthesis

The theorems proved in this cycle — the chi-squared mutual information bound, entropy deletion lower bound, and susceptibility bound — reveal that robust Lorentzianity is not merely an algebraic curiosity but an *information-theoretic organizing principle*. The spectral gap ε simultaneously controls pairwise information sharing (mutual information ≤ O(1/ε)), entropy stability under deletion (loss ≤ log 2), and global correlation structure (susceptibility ≤ n/4). These results open a rich landscape of follow-up work, from sharpening the bounds to extending the framework to continuous settings and connecting to active research in privacy, optimization, and physics.

The five directions below are ordered by increasing ambition: Directions 1-3 are solid extensions building directly on the proved theorems, while Directions 4-5 are grand-challenge conjectures that, if resolved, would establish entirely new research programs.

---

## Direction 1: Sharp Logarithmic Mutual Information Bound

**Conjecture:** For every robustly Lorentzian measure μ with gap ε > 0 and distinct coordinates i ≠ j:

I(X_i; X_j) ≤ C · log(1 + 1/ε)

for a universal constant C > 0. This improves the proved bound of O(1/ε) to O(log(1/ε)).

**Test:** Compute exact mutual information for uniform matroids U(k,n) with varying k and n. Fit the data to both 1/ε and log(1+1/ε) models. The conjecture predicts the logarithmic fit will have strictly smaller residuals across all tested families.

**Impact:** A logarithmic MI bound would establish that robust Lorentzianity is a much stronger information contraction principle than the current chi-squared bound suggests. It would imply near-independence of coordinate pairs, with applications to privacy amplification where each additional level of Lorentzian gap provides only logarithmic information leakage.

**Catalog References:** `Catalog/Bridges/Catalog/Pythagorean/RobustLorentzianSampling.lean` (robust_quadform_negativity), `Catalog/Pythagorean/LorentzianInfoTheory.lean` (mutualInfo_cov_bound)

**Proof Strategy:** Replace the chi-squared → MI pathway with a direct KL divergence bound. The key insight is that for binary variables with small covariance c and marginals bounded away from 0 and 1, the KL divergence D(P_{XY} || P_X ⊗ P_Y) admits a Taylor expansion where the leading term is c²/(2p(1-p)q(1-q)) but higher-order terms provide the logarithmic improvement. Use Real.log_le_sub_one_of_le from Mathlib for the analytical core.

**Domain Bridges:** Information theory (KL divergence bounds), probability theory (concentration of Bernoulli products)

**Lineage:** Direct sharpening of `mutualInfo_cov_bound`

**Ambition:** Solid extension — builds directly on proved infrastructure

The key insight is that the chi-squared divergence vastly overestimates mutual information for binary variables with controlled covariance, because chi-squared ignores the logarithmic nature of KL divergence. Why now? The formal verification infrastructure for handling Real.log inequalities in Lean 4 with Mathlib has matured to the point where analytic bounds involving logarithms are tractable.

---

## Direction 2: Formal Shearer Inequality for Subset Laws

**Conjecture:** For any FinsetLaw μ on [n], any family of coordinate subsets A_1,...,A_m covering each coordinate at least r times:

H(μ) ≤ (1/r) Σ_t H(projectToSet(μ, A_t))

This is the classical Shearer inequality, which we conjecture can be formalized in Lean 4 using the entropy infrastructure developed in this cycle.

**Test:** Verify computationally for all uniform matroids U(k,n) with n ≤ 8 and all possible covering families with m ≤ 10. The inequality should hold with equality only for product distributions.

**Impact:** A formal Shearer inequality would be the first machine-verified proof of this fundamental result in discrete information theory. Combined with the Lorentzian framework, it would yield tight entropy covering bounds for negatively dependent distributions.

**Catalog References:** `Catalog/Pythagorean/LorentzianInfoTheory.lean` (totalEntropy, projectToSet, totalEntropy_nonneg)

**Proof Strategy:** Prove by induction on n. The base case n=1 is trivial. For the inductive step, use the chain rule H(X_1,...,X_n) = H(X_1 | X_2,...,X_n) + H(X_2,...,X_n) and the fact that conditioning reduces entropy. The covering condition ensures each coordinate appears enough times to apply the chain rule bound. The key lemma is entropy submodularity: H(X_A) + H(X_B) ≥ H(X_{A∪B}) + H(X_{A∩B}).

**Domain Bridges:** Combinatorics (covering designs), information theory (chain rule, submodularity)

**Lineage:** Extends `totalEntropy_nonneg` and `projectToSet`

**Ambition:** Solid extension — requires new entropy chain rule infrastructure

The key insight is that entropy submodularity, once formalized, makes Shearer's inequality an immediate consequence of linear programming duality over the coverage polytope. Why now? The `totalEntropy` and `projectToSet` definitions are now in place, providing the right abstractions for stating and proving the chain rule.

---

## Direction 3: Entropy Decay Along Coordinate Deletion Chains

**Conjecture:** For a robustly Lorentzian measure μ with gap ε on [n], repeatedly deleting coordinates produces a monotone entropy sequence:

H(μ) ≥ H(π_{k₁} μ) ≥ H(π_{k₂} π_{k₁} μ) ≥ ... ≥ 0

with each step losing at most log 2, and the total loss after deleting m coordinates is at most m · log 2.

**Test:** Compute entropy along all possible deletion orderings for U(k,n) with n ≤ 8. Verify monotonicity and the m · log 2 bound. Test whether the actual loss is subadditive (total loss < sum of individual losses).

**Impact:** This would establish that robustly Lorentzian measures have a well-defined "entropy spectrum" under deletion, analogous to the singular value spectrum in linear algebra. This connects to privacy amplification by composition: each deletion provides bounded information leakage, and the total leakage after multiple deletions is controlled.

**Catalog References:** `Catalog/Pythagorean/LorentzianInfoTheory.lean` (entropy_delete_lower_bound, deleteCoordPushforward)

**Proof Strategy:** Iterate `entropy_delete_lower_bound`. The main technical challenge is showing that the deletion pushforward of a robustly Lorentzian measure remains robustly Lorentzian (possibly with a degraded gap). This requires tracking how marginals and covariances transform under deletion — a natural extension of the `deleteCoordPushforward` infrastructure.

**Domain Bridges:** Differential privacy (composition theorems), signal processing (progressive compression)

**Lineage:** Direct iteration of `entropy_delete_lower_bound`

**Ambition:** Solid extension — requires preservation of Lorentzianity under deletion

The key insight is that the log 2 bound is universal and doesn't require Lorentzianity, so the composition bound m · log 2 holds trivially. The deeper question is whether Lorentzianity gives a tighter composition bound (e.g., √m · log 2). Why now? The deletion pushforward infrastructure is complete and the single-step bound is proved.

---

## Direction 4: Lorentzian Entropy Power Inequality

**Conjecture:** For two independent robustly Lorentzian measures μ₁, μ₂ on [n] with gaps ε₁, ε₂, the "convolution" (product and projection) satisfies an entropy power inequality:

exp(2H(μ₁ * μ₂)/n) ≥ exp(2H(μ₁)/n) + exp(2H(μ₂)/n) - C(ε₁, ε₂)

for an explicit correction term C depending on the gaps.

**Test:** Compute both sides for products of uniform matroids and verify the inequality. The correction term should vanish as ε₁, ε₂ → 0 (approaching independence).

**Impact:** This would be a discrete analogue of the celebrated Shannon-Stam entropy power inequality, which is one of the deepest results in continuous information theory. A Lorentzian version would establish that negative dependence plays the role of Gaussianity in the discrete setting, fundamentally changing our understanding of entropy in combinatorial probability.

**Catalog References:** `Catalog/Pythagorean/LorentzianInfoTheory.lean` (totalEntropy, FinsetLaw), `Catalog/Bridges/Catalog/Pythagorean/RobustLorentzianSampling.lean` (robust_quadform_negativity)

**Proof Strategy:** Approach via the Fisher information route used in the continuous EPI proof. Define a discrete Fisher information for FinsetLaw measures and show that Lorentzian negativity provides the concavity needed for de Bruijn's identity. The generating polynomial's Hessian structure should play the role of the covariance matrix in the continuous theory.

**Domain Bridges:** Information theory (entropy power inequality), probability theory (central limit theorems), physics (free energy additivity)

**Lineage:** Grand synthesis of entropy bounds and Lorentzian structure

**Ambition:** Grand challenge — would establish a new paradigm in discrete information theory

The key insight is that the Lorentzian Hessian condition (at most one positive eigenvalue) is the discrete analogue of the Gaussian's Hessian structure, which is precisely what makes the continuous EPI work. Why now? The formalization of total entropy and the Lorentzian gap predicate provides the definitional infrastructure needed to even state this conjecture precisely.

---

## Direction 5: Lorentzian Phase Transition Classification

**Conjecture:** The susceptibility bound χ ≤ n/4 is the first case of a general phenomenon: robustly Lorentzian measures cannot exhibit second-order phase transitions. More precisely, define a family of Lorentzian measures μ_β parametrized by inverse temperature β. Then the free energy F(β) = -log Z(β) is always analytic in β (no singularities), and all thermodynamic quantities (susceptibility, specific heat, magnetization) remain bounded.

**Test:** Construct explicit one-parameter families of robustly Lorentzian measures (e.g., exponentially tilted matroids) and compute thermodynamic quantities as functions of β. Verify analyticity and boundedness. Check whether the Lee-Yang theorem (zeros of the partition function) is consistent with the Lorentzian condition.

**Impact:** This would establish that Lorentzian negativity is a *topological obstruction* to phase transitions — it prevents the formation of long-range order that characterizes critical phenomena. This would be a paradigm-shifting result connecting algebraic geometry (Lorentzian polynomials) to the foundations of statistical mechanics (phase transition theory).

**Catalog References:** `Catalog/Pythagorean/LorentzianInfoTheory.lean` (susceptibility_bound_of_robust, spinSusceptibility), `Catalog/Bridges/Catalog/Pythagorean/RobustLorentzianSampling.lean` (gibbs_weight_ratio_bound)

**Proof Strategy:** Use the Lee-Yang theorem: a polynomial has no zeros in a region iff its logarithmic derivative is analytic there. The Lorentzian condition constrains the zero locations of the generating polynomial. If all zeros lie outside a strip around the real axis (as the Lorentzian condition suggests), then the free energy is analytic on the real axis, proving absence of phase transitions.

**Domain Bridges:** Statistical mechanics (phase transitions, Lee-Yang theory), algebraic geometry (polynomial zero loci), complex analysis (analytic continuation)

**Lineage:** Grand extension of susceptibility bound to full thermodynamic theory

**Ambition:** Grand challenge — would unify Lorentzian polynomial theory with statistical mechanics

The key insight is that the susceptibility bound χ ≤ n/4 is a "zero-temperature" shadow of a much deeper statement about the entire temperature axis: the Lorentzian structure prevents the divergences that signal phase transitions at any temperature. Why now? The formal susceptibility bound provides the first rigorous evidence that Lorentzian negativity has thermodynamic consequences, and the `gibbs_weight_ratio_bound` from the catalog provides the perturbation stability needed to vary temperature.
