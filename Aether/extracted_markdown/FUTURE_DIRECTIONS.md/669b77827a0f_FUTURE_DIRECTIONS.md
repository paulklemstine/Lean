# Future Directions: Idempotent KME Support Duality

This document outlines concrete next breakthroughs enabled by the support duality
and identifiability theorems for tropical kernel mean embeddings.

## 1. Tropical Characteristic Kernels for Maxitive Measures

**Problem.** A kernel `k` is called *characteristic* if the tropical KME map
`w ↦ tropKME(k, w)` is injective on the space of all maxitive measures (weight
profiles). Our `TropSeparatingKernel` structure axiomatizes this property via
residuation. The next step is to *classify* characteristic kernels.

**Concrete targets:**
- Prove that the tropical Kronecker (Dirac) kernel on EReal is characteristic.
- Characterize characteristic kernels in terms of the tropical rank of the
  kernel matrix.
- Show that generic real-valued kernels are *not* characteristic on EReal-valued
  weight profiles, but are characteristic on bounded weight profiles.
- Define a tropical MMD (maximum mean discrepancy) metric:
  `d(μ, ν) = sup_y |tropKME(k, μ)(y) - tropKME(k, ν)(y)|`
  and prove it is a metric when `k` is characteristic.

**Why it matters.** This gives a computable statistical divergence for maxitive
measures, enabling hypothesis testing and distribution comparison in the tropical
setting.

## 2. Stone Duality for Idempotent KMEs on Boolean Algebras of Clopens

**Problem.** The clopen witness characterization (`not_mem_supp_iff_exists_clopen_discrete`)
currently holds only on discrete spaces. The natural extension is to compact
totally disconnected (Stone) spaces.

**Concrete targets:**
- Define `MaxitiveMeasure` on general topological spaces via the Shilkret integral.
- Prove that on compact Hausdorff zero-dimensional spaces, the topological support
  coincides with the set of points where every clopen neighborhood has non-⊥ mass.
- Establish a Stone-type duality: the tropical KME factors through the Boolean
  algebra of clopens, and the factorization is a categorical equivalence between
  maxitive measures on Stone spaces and certain tropical linear functionals on
  the corresponding Boolean algebra.
- Prove that this duality is natural in continuous maps (functoriality).

**Why it matters.** This connects the tropical KME to point-free topology and
spectral theory, opening the door to non-commutative tropical measure theory
and connections to domain theory in computer science.

## 3. Algorithmic Recovery Bounds from Partial Witness Data

**Problem.** In practice, one observes only finitely many witness evaluations
`tropKME(k, w)(y_1), ..., tropKME(k, w)(y_m)`. When can we reconstruct the
full weight profile `w` from partial data?

**Concrete targets:**
- Prove that on `|X| = n`, exactly `n` witness evaluations at well-chosen
  points suffice for full reconstruction under a separating kernel.
- Quantify the stability: if evaluations are perturbed by `ε`, bound the
  reconstruction error `‖w - w_reconstructed‖` in terms of `ε` and the
  kernel's condition number.
- Implement a tropical reconstruction algorithm with provable guarantees.
- Extend to approximate reconstruction when the kernel is not perfectly
  separating (tropical regularization).

**Why it matters.** This gives an algorithmic pipeline for learning sparse
maxitive measures from data — the tropical analogue of kernel density estimation.

## 4. Maxitive MMD / Witness Metric with Identifiability Guarantees

**Problem.** Define a metric on maxitive measures via the KME and prove it
metrizes a natural topology.

**Concrete targets:**
- Define `tropMMD(k, μ, ν) = ‖tropKME(k, μ) - tropKME(k, ν)‖_∞` where the
  norm is the sup-norm in EReal (appropriately truncated).
- Prove: `tropMMD(k, μ, ν) = 0 ↔ μ = ν` when `k` is characteristic.
- Show that `tropMMD` metrizes the topology of pointwise convergence of
  weight profiles on finite types.
- Prove convergence rates: if `μ_n → μ` in tropMMD, bound the rate of
  convergence of supports `supp(μ_n) → supp(μ)` in Hausdorff distance.
- Implement statistical tests based on tropMMD for two-sample problems
  with maxitive (possibility) measures.

**Why it matters.** This provides the tropical analogue of the kernel-MMD
framework that has been transformative in classical statistics and machine
learning. Applications include anomaly detection with possibility measures
and robustness certification for max-plus neural networks.

## 5. Categorical Functoriality of the KME Under Pullback/Pushforward

**Problem.** The assignment `μ ↦ tropKME(k, μ)` should be functorial in an
appropriate category.

**Concrete targets:**
- Define the category of maxitive measures on finite types with morphisms
  being measure-preserving maps.
- Show that tropKME is a functor from this category to a category of
  tropical functional modules.
- Prove that pullback and pushforward of maxitive measures are compatible
  with KME computation: if `f : X → Y` is a morphism, then
  `tropKME(k_Y, f_*(μ)) = f^* ∘ tropKME(f^* k_Y, μ)`.
- Establish naturality of the identifiability theorem: the support map
  `μ ↦ supp(μ)` is a natural transformation from the maxitive measure
  functor to the powerset functor.

**Why it matters.** Functoriality ensures that the KME framework is compatible
with data transformations, enabling transfer learning and domain adaptation
for tropical models.

## Technical Prerequisites

The following Lean infrastructure would accelerate progress on all five directions:

1. **EReal-valued kernels**: Extend `TropSeparatingKernel` to allow `k : α → α → EReal`,
   with the Kronecker kernel as the canonical example.
2. **Continuous maxitive measures**: Define maxitive measures on general topological
   spaces via the Shilkret integral and prove the portmanteau-type convergence theorem.
3. **Tropical linear algebra**: Formalize tropical rank, tropical eigenvalues, and
   the max-plus permanent for kernel matrices.
4. **Finite approximation**: Prove that every maxitive measure on a compact space
   is a limit of finitely supported maxitive measures in an appropriate topology.
