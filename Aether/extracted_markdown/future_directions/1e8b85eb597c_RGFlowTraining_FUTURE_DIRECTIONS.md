# Future Directions: Neural Network Training as Renormalization-Group Flow

## Synthesis

This cycle takes the spectral theory of NTK training already in the catalog
(`MachineLearning/NTKSpectral.lean`: `ntkGram`, `ntk_mode_decay`,
`optimal_lr_contraction`, `ntk_optimal_tendsto_zero`) and recasts it as a
**discrete renormalization-group (RG) flow** in `MachineLearning/RGFlowTraining.lean`.
A single gradient step becomes a diagonal flow `rgStep` on the space of spectral
modes, rescaling each mode `i` by its gain `g_i = 1 - η λ_i`. From this one object
we proved, fully `sorry`-free and on only the standard axioms:

* `rgStep_iterate` — the flow's closed form `g_i^k v_i` (multi-mode lift of
  `NTKSpectral.ntk_mode_decay`);
* `rgStep_semigroup` — training steps form a one-parameter RG semigroup;
* `rg_scale_separation` — fast (high-frequency) modes vanish *relative* to slow
  modes: the precise sense in which training "integrates out" UV degrees of freedom;
* `rgStep_fixed_iff` — the IR fixed manifold of the flow is exactly the kernel of
  the NTK;
* `rg_flow_tendsto_zero` — contracting spectra flow to the IR fixed point
  (multi-mode lift of `NTKSpectral.ntk_optimal_tendsto_zero`).

## Results Summary

The "training = RG flow" slogan is now a theorem-level dictionary:
gain ↔ RG eigenvalue, eigenvalue magnitude ↔ scaling dimension (relevant vs.
irrelevant), NTK kernel ↔ IR fixed point, geometric mode ratio ↔ separation of
scales. The whole development is diagonal and discrete by design, which is what made
clean, axiom-minimal proofs possible while staying faithful to what optimizers run.

## Research Directions

### 1. A genuine RG group law with explicit scaling dimensions
The current `rgStep_semigroup` is the additive iterate law; the next step is to
define a *continuous-time* flow `Φ_t v i = exp(-t λ_i) v_i` and prove `Φ_s ∘ Φ_t =
Φ_{s+t}` together with the eigenvalue's role as a **scaling dimension**: mode `i` is
relevant, marginal, or irrelevant according to `λ_i <, =, > 0` (about a shifted
fixed point). **The key insight is** that gradient flow is literally a heat
semigroup in the NTK eigenbasis, so RG "scaling dimensions" are NTK eigenvalues and
the relevant/irrelevant trichotomy is a sign condition. *Why now?* `rgStep_iterate`
already gives the discrete analogue, and Mathlib's `Real.exp` semigroup lemmas make
the continuous law a short reach — turning a discrete picture into a true flow.

### 2. Universality / scaling collapse of the loss curve
Conjecture: under `rg_flow_tendsto_zero` the training loss
`L_k = ∑_i (g_i^k v_i)^2` obeys a **two-regime scaling law** — an early plateau set
by the slowest mode `g_max = max_i |g_i|` and a final rate `L_k ≍ g_max^{2k}` — and
the rescaled curve `L_k / g_max^{2k}` converges to a mode-count constant independent
of the data. **The key insight is** that the slowest relevant mode dominates the
long-time flow, so the loss curve is universal up to the single number `g_max`, a
direct analogue of critical-exponent universality. *Why now?* `rgStep_iterate`
already diagonalizes `L_k` into a finite sum of geometric sequences, so the dominant
term and the limit constant are extractable with Mathlib's `Finset.sum` asymptotics.

### 3. The IR fixed manifold as a generalization frontier
`rgStep_fixed_iff` identifies fixed residuals with the NTK kernel. Conjecture: the
flow's limit point of an arbitrary initialization is the **orthogonal projection of
the initial residual onto that kernel**, and its norm lower-bounds the achievable
test error. **The key insight is** that training cannot move residual components
that lie in the NTK kernel, so the kernel is an exact, computable obstruction to
fitting — a spectral "no-go" theorem for the linearized model. *Why now?* We already
have the fixed-point characterization and per-mode convergence; combining them with
Mathlib's orthogonal-projection API turns "what does training converge to" into a
provable linear-algebra identity.

### 4. Coarse-graining maps that change the number of modes
Real RG integrates out modes, reducing dimension. Define a coarse-graining
`block : (Fin (d₁+d₂) → ℝ) → (Fin d₁ → ℝ)` that drops the fast block and prove the
**commuting square** `block ∘ rgStep_{full} = rgStep_{slow} ∘ block` asymptotically
(exactly in the limit of infinite scale separation). **The key insight is** that
when `max_{fast} |g| < min_{slow} |g|`, the effective theory on the slow modes is
itself an `rgStep`, so the RG step is *closed* under coarse-graining — the defining
property of a renormalization group. *Why now?* `rg_scale_separation` already proves
the fast/slow amplitude collapse that makes the square commute; promoting it to an
operator identity is the natural next theorem.

### 5. Stochastic gradient descent as a noisy RG flow
Replace `rgStep` by `v ↦ (g_i v_i + ξ_i)` with bounded i.i.d. mode noise `ξ`.
Conjecture: the flow no longer reaches `0` but converges in distribution to a
**stationary measure** whose per-mode variance scales as `σ²/(1 - g_i²)` — large for
slow (relevant) modes, small for fast (irrelevant) ones. **The key insight is** that
SGD noise sets a finite RG "temperature", and the fluctuation–dissipation balance
`variance ∝ 1/(1-g²)` means relevant modes carry essentially all the late-time
fluctuation. *Why now?* The deterministic contraction is fully proved here, and
Mathlib's geometric-series and probability infrastructure make the stationary-variance
identity a tractable, falsifiable next target that bridges optimization, RG, and
statistical mechanics.
